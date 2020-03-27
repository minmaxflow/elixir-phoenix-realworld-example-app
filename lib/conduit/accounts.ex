defmodule Conduit.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Conduit.Repo

  alias Conduit.Accounts.User

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # 可能会更新密码
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def register_user(params) do
    %User{}
    |> User.register_chagneset(params)
    |> Repo.insert()
  end

  def authenticate_by_username_password(email, password) do
    user = get_user_by(email: email)

    cond do
      user && Pbkdf2.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
