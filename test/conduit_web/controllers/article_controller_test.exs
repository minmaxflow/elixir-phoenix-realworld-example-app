defmodule ConduitWeb.ArticleControllerTest do
  use ConduitWeb.ConnCase

  alias Conduit.Blog.Article

  import ConduitWeb.Guardian

  @create_attrs %{
    body: "some body",
    description: "some description",
    title: "some title",
    tagList: ["tag1", "tag2"]
  }
  @update_attrs %{
    body: "some updated body",
    description: "some updated description",
    title: "some updated title",
    tagList: ["tag2", "tag3"]
  }
  @invalid_attrs %{body: nil, description: nil, slug: nil, title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all articles", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index))
      assert json_response(conn, 200)["articles"] == []
    end
  end

  describe "create article" do
    setup [:create_article, :auth_conn]

    test "renders article when data is valid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @create_attrs)
      assert %{"slug" => slug} = json_response(conn, 201)["article"]

      conn = get(conn, Routes.article_path(conn, :show, slug))

      assert %{
               "slug" => ^slug,
               "body" => "some body",
               "description" => "some description",
               "title" => "some title",
               "tagList" => tagList
             } = json_response(conn, 200)["article"]

      assert Enum.sort(tagList) == Enum.sort(@create_attrs.tagList)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update article" do
    setup [:create_article, :auth_conn]

    test "renders article when data is valid", %{
      conn: conn,
      article: %Article{slug: slug} = article
    } do
      conn = put(conn, Routes.article_path(conn, :update, article), article: @update_attrs)
      assert %{"slug" => new_slug} = json_response(conn, 200)["article"]

      assert String.slice(slug, -12..-1) == String.slice(new_slug, -12..-1)

      conn = get(conn, Routes.article_path(conn, :show, new_slug))

      assert %{
               "slug" => new_slug,
               "body" => "some updated body",
               "description" => "some updated description",
               "title" => "some updated title",
               "tagList" => tagList
             } = json_response(conn, 200)["article"]

      assert Enum.sort(tagList) == Enum.sort(@update_attrs.tagList)
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn = put(conn, Routes.article_path(conn, :update, article), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete article" do
    setup [:create_article, :auth_conn]

    test "deletes chosen article", %{conn: conn, article: article} do
      conn = delete(conn, Routes.article_path(conn, :delete, article))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.article_path(conn, :show, article))
      end
    end
  end

  defp create_article(_) do
    user = insert_user()
    article = insert_article(user)
    {:ok, user: user, article: article}
  end

  # 这个和profile_controller的做法不一样
  defp auth_conn(%{conn: conn, user: user}) do
    {:ok, token, _} = encode_and_sign(user)

    conn =
      conn
      |> put_req_header("authorization", "Token " <> token)

    {:ok, conn: conn}
  end
end
