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

  alias Conduit.Accounts.User
  alias Conduit.Accounts.UserFollower

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

  alias Conduit.Blog.Article

  def list_articles(_user, _params) do
    Repo.all(Article)
  end

  def get_article_by_slug!(current_user, slug) do
    base_query = from a in Article, where: a.slug == ^slug

    base_query
    |> build_article_query(current_user)
    |> Repo.one!()
    |> fix_author_following()
  end

  def get_user_article_by_slug!(%User{} = current_user, slug) do
    base_query = from a in Article, where: a.slug == ^slug and a.author_id == ^current_user.id

    base_query
    |> build_article_query(current_user)
    |> Repo.one!()
    |> fix_author_following()
  end

  defp fix_author_following(article) do
    %{article | author: %{article.author | following: article.following}}
  end

  defp build_article_query(base_query, current_user, filters \\ %{}) do
    base_query
    |> preload_tag()
    |> preload_author(current_user)
    |> preload_favorite(current_user)
    |> maybe_filter_by_tag(filters[:tag])
    |> maybe_filter_by_author(filters[:author])
  end

  defp preload_tag(query) do
    from _ in query, preload: [:tags]
  end

  defp preload_author(query, current_user) do
    # 主键现在都是uuid类型
    uid =
      case current_user do
        nil -> Ecto.UUID.generate()
        current_user -> current_user.id
      end

    # 通过left join来判定是否current_user是否follow文章作者
    from(article in query,
      join: author in User,
      on: author.id == article.author_id,
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
    # 同时注意 position binding 对调用顺序的依赖
    from([article, _, uf] in query,
      left_join: fav in Favorite,
      on: fav.article_id == article.id,
      group_by: [article.id, uf.follower_id],
      select_merge: %{
        favorites_count: count(fav.user_id),
        favorited: fragment("max(case ? when ? then 1 else 0 end  ) = 1", fav.user_id, ^uid) != 0
      }
    )
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
      where: author.name == ^author_name
    )
  end

  # todo 

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

    favorite = Repo.get_by!(Favorite, user_id: user_id, article: article.id)

    Repo.delete(favorite)
  end

  # comment 
end
