defmodule Conduit.TestHelpers do
  alias Conduit.Accounts
  alias ConduitWeb.Guardian

  defp default_user() do
    num = System.unique_integer([:positive])

    %{
      username: "user#{num}",
      email: "user#{num}@test.com",
      bio: "user bio",
      image: nil,
      password: "password"
    }
  end

  def insert_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(default_user())
      |> Accounts.register_user()

    user
  end

  def login(%{conn: conn, login_as: username}) do
    user = insert_user(%{username: username})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> Plug.Conn.put_req_header("authorization", "Token: " <> token)

    {conn, user}
  end
end
