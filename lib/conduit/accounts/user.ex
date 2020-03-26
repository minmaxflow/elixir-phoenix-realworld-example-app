defmodule Conduit.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :bio, :string
    field :email, :string
    field :image, :string
    field :username, :string
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :bio, :image])
    |> validate_required([:email, :username, :bio, :image])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
