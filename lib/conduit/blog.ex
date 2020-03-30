defmodule Conduit.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto
  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Conduit.Repo

  alias Conduit.Blog.Tag
  alias Conduit.Blog.Article
  alias Conduit.Blog.Favorite
  alias Conduit.Blog.Comment

  alias Conduit.Accounts.User
  alias Conduit.Accounts.UserFollower

  # tag

  def list_tags do
    Repo.all(Tag)
  end

  def get_or_insert_tags([]) do
    []
  end

  def get_or_insert_tags(names) do
    utc_now = DateTime.truncate(DateTime.utc_now(), :second)

    # insert_all 需要手动生成timestamp
    maps =
      Enum.map(
        names,
        &%{name: &1, updated_at: utc_now, created_at: utc_now}
      )

    Repo.insert_all(Tag, maps, on_conflict: :nothing)
    Repo.all(from t in Tag, where: t.name in ^names)
  end

  # article

  def list_articles(current_user, filters \\ %{}) do
    base_query = from(a in Article)

    base_query
    |> build_article_query(current_user, filters)
    |> Repo.all()
    |> fix_article_author_following()
  end

  def list_feed_articles(current_user, filters \\ %{}) do
    base_query = from(a in Article)

    base_query
    |> build_article_query(current_user, filters)
    |> follow_query(current_user)
    |> Repo.all()
    |> fix_article_author_following()
  end

  # 注意：SQL没有那么智能，不要重复Join相同的表，否则group那块会有问题
  defp follow_query(query, current_user) do
    # 限制是当前用户follow的用户
    from [_, u, uf] in query,
      where: uf.follower_id == ^current_user.id and uf.followee_id == u.id
  end

  def get_article_by_slug!(current_user, slug) do
    base_query = from a in Article, where: a.slug == ^slug

    base_query
    |> build_article_query(current_user)
    |> Repo.one!()
    |> fix_article_author_following()
  end

  def get_user_article_by_slug!(%User{} = current_user, slug) do
    base_query =
      from a in Article,
        where: a.slug == ^slug and a.author_id == ^current_user.id

    base_query
    |> build_article_query(current_user)
    |> Repo.one!()
    |> fix_article_author_following()
  end

  defp fix_article_author_following(articles) when is_list(articles) do
    Enum.map(articles, &fix_article_author_following(&1))
  end

  defp fix_article_author_following(article) do
    %{article | author: %{article.author | following: article.following}}
  end

  defp build_article_query(base_query, current_user, filters \\ %{}) do
    # 兼容两种格式
    filters = Enum.into(filters, %{}, fn {key, value} -> {to_string(key), value} end)

    base_query
    |> order_by_recent()
    |> preload_tag()
    |> preload_article_author(current_user)
    |> preload_favorite(current_user)
    |> maybe_filter_by_tag(filters["tag"])
    |> maybe_filter_by_author(filters["author"])
    |> maybe_filter_by_favorited(filters["favorited"])
    |> paginate(filters["offset"], filters["limit"])
  end

  defp order_by_recent(query) do
    from a in query, order_by: [desc: a.created_at]
  end

  defp preload_tag(query) do
    from _ in query, preload: [:tags]
  end

  defp preload_article_author(query, current_user) do
    # 主键现在都是uuid类型
    uid =
      case current_user do
        nil -> Ecto.UUID.generate()
        current_user -> current_user.id
      end

    # 通过left join来判定是否current_user是否follow文章作者
    from(article in query,
      join: author in assoc(article, :author),
      left_join: uf in UserFollower,
      on: author.id == uf.followee_id and uf.follower_id == ^uid,
      # preload: [author: %{author | following: not is_nil(uf.follower_id)}]       
      # Ecto暂时不支持上面这种preload方式
      # 受限于preload的限制， 在通过join preload的时候，User对象的following不能一步计算完成
      # 需要先映射到Article的这个字段，然后再复制到User对象
      preload: [author: author],
      select_merge: %{
        following: not is_nil(uf.follower_id)
      }
    )
  end

  # 计算favorited以及favorites_count
  defp preload_favorite(query, current_user) do
    # 主键现在都是uuid类型
    uid =
      case current_user do
        nil -> Ecto.UUID.generate()
        current_user -> current_user.id
      end

    # 为了能够count，需要group_by
    #   其中article.id肯定是需要的，但是没有uf.follower_id, mysql会报错，uf.follower_id是一个常量，所以放入里面也没有问题
    # 注意 
    #   1 position binding 对调用顺序的依赖
    #   2 binary_id类型在fragment里面使用需要明确进行type cast
    query =
      from([article, _, uf] in query,
        left_join: fav in Favorite,
        on: fav.article_id == article.id,
        group_by: [article.id, uf.follower_id],
        select_merge: %{
          favorites_count: count(fav.user_id),
          favorited:
            fragment(
              "max(case ? when ? then 1 else 0 end  ) = 1",
              fav.user_id,
              type(^uid, :binary_id)
            ) != 0
        }
      )

    # debug sql 
    # Repo.to_sql(:all, query) |> IO.inspect()

    query
  end

  defp maybe_filter_by_tag(query, nil), do: query

  defp maybe_filter_by_tag(query, tag_name) do
    from(article in query,
      join: tag in assoc(article, :tags),
      where: tag.name == ^tag_name
    )
  end

  defp maybe_filter_by_author(query, nil), do: query

  defp maybe_filter_by_author(query, author_name) do
    from(article in query,
      join: author in assoc(article, :author),
      where: author.username == ^author_name
    )
  end

  defp maybe_filter_by_favorited(query, nil), do: query

  defp maybe_filter_by_favorited(query, user_name) do
    from(article in query,
      join: fav in Favorite,
      on: article.id == fav.article_id,
      join: u in User,
      on: fav.user_id == u.id,
      where: u.username == ^user_name
    )
  end

  defp may_paginate(query, nil, nil) do
    query
  end

  defp may_paginate(query, offset, limit) do
    paginate(query, offset, limit)
  end

  defp paginate(query, offset, limit) do
    offset = String.to_integer(offset || "0")
    limit = String.to_integer(limit || "20")

    query
    |> limit(^limit)
    |> offset(^offset)
  end

  # article create|update|delete

  def create_article(%User{} = user, params) do
    tagList = params["tagList"] || params[:tagList] || []
    tags = get_or_insert_tags(tagList)

    user
    |> build_assoc(:articles)
    |> Article.changeset(params)
    |> put_assoc(:tags, tags)
    |> Repo.insert()
  end

  def update_article(%Article{} = article, params) do
    tagList = params["tagList"] || params[:tagList] || []
    tags = get_or_insert_tags(tagList)

    article
    # in case tags is not preload    
    |> Repo.preload(:tags)
    |> Article.changeset(params)
    |> put_assoc(:tags, tags)
    |> Repo.update()
  end

  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  # favorite

  def favorite_article(%User{id: user_id}, slug) do
    article = Repo.get_by!(Article, slug: slug)

    %Favorite{user_id: user_id, article_id: article.id}
    |> Favorite.changeset()
    |> Repo.insert()
  end

  def unfavorite_article(%User{id: user_id}, slug) do
    article = Repo.get_by!(Article, slug: slug)

    favorite = Repo.get_by!(Favorite, user_id: user_id, article_id: article.id)

    Repo.delete(favorite)
  end

  # comment 

  def list_article_comments(current_user, filters \\ %{}) do
    base_query = from(c in Comment)

    base_query
    |> build_comment_query(current_user, filters)
    |> Repo.all()
    |> fix_comment_author_following()
  end

  def get_comment!(current_user, slug, comment_id) do
    base_query = from c in Comment, where: c.id == ^comment_id

    filters = %{slug: slug}

    base_query
    |> build_comment_query(current_user, filters)
    |> Repo.one!()
    |> fix_comment_author_following()
  end

  defp fix_comment_author_following(comments) when is_list(comments) do
    Enum.map(comments, &fix_comment_author_following(&1))
  end

  defp fix_comment_author_following(comment) do
    %{comment | author: %{comment.author | following: comment.following}}
  end

  defp build_comment_query(base_query, current_user, filters) do
    # 兼容两种格式
    filters = Enum.into(filters, %{}, fn {key, value} -> {to_string(key), value} end)

    base_query
    |> preload_comment_author(current_user)
    |> maybe_filter_by_slug(filters["slug"])
    # 评论的分页是可选
    |> may_paginate(filters["offset"], filters["limit"])
  end

  defp preload_comment_author(query, current_user) do
    # 主键现在都是uuid类型
    uid =
      case current_user do
        nil -> Ecto.UUID.generate()
        current_user -> current_user.id
      end

    # 通过left join来判定是否current_user是否follow评论作者
    from(comment in query,
      join: author in assoc(comment, :author),
      left_join: uf in UserFollower,
      on: author.id == uf.followee_id and uf.follower_id == ^uid,
      preload: [author: author],
      select_merge: %{
        following: not is_nil(uf.follower_id)
      }
    )
  end

  defp maybe_filter_by_slug(query, nil) do
    query
  end

  defp maybe_filter_by_slug(query, slug) do
    from c in query,
      join: a in assoc(c, :article),
      where: a.slug == ^slug
  end

  def create_user_comment(%User{id: user_id}, slug, attrs) do
    article = Repo.get_by!(Article, slug: slug)

    %Comment{author_id: user_id, article_id: article.id}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end
end
