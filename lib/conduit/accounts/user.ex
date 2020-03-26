defmodule Conduit.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :bio, :string
    field :email, :string
    field :image, :string
    field :username, :string
    field :password_hash, :string

    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :bio, :image])
    |> validate_required([:email, :username, :bio, :image])
    |> validate_length(:username, min: 3, max: 20)
    # refer: https://gist.github.com/mgamini/4f3a8bc55bdcc96be2c6
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def register_chagneset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required([:password])
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case fetch_change(changeset, :password) do
      :error -> changeset
      {:ok, password} -> put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
    end
  end
end
