defmodule Conduit.Blog.Article do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Blog.Permalink

  alias Conduit.Accounts.User
  alias Conduit.Blog.Tag

  schema "articles" do
    field :body, :string
    field :description, :string
    field :slug, Permalink
    field :title, :string

    belongs_to :author, User, foreign_key: :author_id
    many_to_many :tags, Tag, join_through: "articles_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :description, :body])
    |> validate_required([:title, :description, :body])
    |> validate_length(:title, min: 3)
    |> unique_constraint(:slug)
    |> add_slug()
  end

  def slugify_title(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^A-Za-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  # 先假设不会冲突
  def generate_slug do
    :base64.encode(:crypto.strong_rand_bytes(16))
    |> String.replace(~r/[^A-Za-z0-9]/, "")
    |> String.slice(0, 12)
    |> String.downcase()
  end

  defp add_slug(changeset) do
    case get_field(changeset, :slug) do
      nil -> put_change(changeset, :slug, generate_slug())
      _ -> changeset
    end
  end
end
