defmodule ConduitWeb.CommentControllerTest do
  use ConduitWeb.ConnCase

  import ConduitWeb.Guardian

  @create_attrs %{
    body: "some body"
  }
  @invalid_attrs %{body: nil}

  describe "index" do
    setup [:create_comment]

    test "lists all comments", %{conn: conn, article: article, comment: %{id: id}} do
      conn = get(conn, Routes.article_comment_path(conn, :index, article))
      assert [%{"id" => ^id}] = json_response(conn, 200)["comments"]
    end
  end

  describe "create comment" do
    setup [:create_comment, :auth_conn]

    test "renders comment when data is valid", %{conn: conn, article: article} do
      conn =
        post(conn, Routes.article_comment_path(conn, :create, article), comment: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["comment"]
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn =
        post(conn, Routes.article_comment_path(conn, :create, article), comment: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete comment" do
    setup [:create_comment, :auth_conn]

    test "deletes chosen comment", %{conn: conn, article: article, comment: comment} do
      conn = delete(conn, Routes.article_comment_path(conn, :delete, article, comment))
      assert response(conn, 204)
    end
  end

  defp create_comment(_) do
    user = insert_user()
    article = insert_article(user)
    comment = insert_comment(user, article)
    {:ok, user: user, article: article, comment: comment}
  end

  defp auth_conn(%{conn: conn, user: user}) do
    {:ok, token, _} = encode_and_sign(user)

    conn =
      conn
      |> put_req_header("authorization", "Token " <> token)

    {:ok, conn: conn}
  end
end
