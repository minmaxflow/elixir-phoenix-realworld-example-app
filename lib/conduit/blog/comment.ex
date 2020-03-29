defmodule Conduit.Blog.Comment do
  use Conduit.Schema

  import Ecto.Changeset

  alias Conduit.Accounts.User
  alias Conduit.Blog.Article

  schema "comments" do
    field :body, :string

    belongs_to :author, User
    belongs_to :article, Article

    # 为了绕开Ecto的限制，具体请看blog里面的代码
    field :following, :boolean, virtual: true, default: false

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
