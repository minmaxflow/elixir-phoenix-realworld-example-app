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

  def get_article!(id) do
    Repo.get!(Article, id) |> Repo.preload([:tags])
  end

  def get_article_by_slug!(user, slug) do
    Article
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:tags])
  end

  def get_user_article_by_slug!(%User{} = user, slug) do
    Article
    |> user_article_query(user)
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:tags])
  end

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

  defp user_article_query(query, %User{id: user_id}) do
    from a in query, where: a.author_id == ^user_id
  end
end
