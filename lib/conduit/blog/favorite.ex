defmodule Conduit.Blog.Favorite do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Blog.Article
  alias Conduit.Accounts.User

  @primary_key false
  schema "favorites" do
    belongs_to :user, User, primary_key: true
    belongs_to :article, Article, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(favorite, attrs \\ %{}) do
    favorite
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:user_id, name: :favorites_user_id_article_id_index)
  end
end
