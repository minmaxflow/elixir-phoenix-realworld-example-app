defmodule Conduit.TestHelpers do
  alias Conduit.Accounts
  alias Conduit.Accounts.User
  alias Conduit.Blog
  alias ConduitWeb.Guardian

  defp default_user() do
    num = System.unique_integer([:positive])

    %{
      username: "user#{num}",
      email: "user#{num}@test.com",
      password: "password"
    }
  end

  defp default_article() do
    num = System.unique_integer([:positive])

    %{
      title: "this is title#{num}",
      description: "description",
      body: "body"
    }
  end

  defp default_comment() do
    %{
      body: "comment body"
    }
  end

  def insert_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(default_user())
      |> Accounts.register_user()

    user
  end

  def insert_article(%User{} = user, attrs \\ %{}) do
    attrs = Enum.into(attrs, default_article())
    {:ok, article} = Blog.create_article(user, attrs)
    article
  end

  def insert_comment(%User{} = user, article, attrs \\ %{}) do
    attrs = Enum.into(attrs, default_comment())
    attrs = Map.put(attrs, :slug, article.slug)
    {:ok, comment} = Blog.create_user_comment(user, attrs)
    comment
  end

  def login(conn, username) do
    user = insert_user(%{username: username})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> Plug.Conn.put_req_header("authorization", "Token " <> token)

    {conn, user}
  end
end
