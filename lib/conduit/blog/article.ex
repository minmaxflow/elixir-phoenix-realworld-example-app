defmodule Conduit.Blog.Article do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Blog.Permalink

  alias Conduit.Accounts.User
  alias Conduit.Blog.Tag
  alias Conduit.Blog.Comment

  schema "articles" do
    field :body, :string
    field :description, :string
    field :slug, Permalink
    field :title, :string

    field :favorited, :boolean, virtual: true, default: false
    field :favorites_count, :integer, virtual: true, default: 0

    # 为了绕开Ecto的限制，具体请看blog里面的代码
    field :following, :boolean, virtual: true, default: false

    belongs_to :author, User
    has_many :comments, Comment
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
