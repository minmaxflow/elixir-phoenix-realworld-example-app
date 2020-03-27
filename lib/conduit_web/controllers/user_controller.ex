defmodule ConduitWeb.UserController do
  use ConduitWeb, :controller

  alias Conduit.Accounts
  alias Conduit.Accounts.User
  alias ConduitWeb.Guardian

  action_fallback ConduitWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      user = %{user | token: token}

      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    # email = user_params["email"]
    # password = user_params["password"]

    with {:ok, user} <- Accounts.authenticate_by_username_password(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      user = %{user | token: token}
      conn |> render("show.json", user: user)
    else
      _ -> {:error, :unauthorized}
    end
  end

  def current(conn, _params) do
    # current_resource可能返回nil
    with user <- Guardian.Plug.current_resource(conn),
         token <- Guardian.Plug.current_token(conn) do
      user = %{user | token: token}
      conn |> render("show.json", user: user)
    else
      _ -> {:error, :unauthorized}
    end
  end

  def update(conn, %{"user" => user_params}) do
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, %User{} = user} <- Accounts.update_user(user, user_params),
         token <- Guardian.Plug.current_token(conn) do
      user = %{user | token: token}
      render(conn, "show.json", user: user)
    end
  end
end
