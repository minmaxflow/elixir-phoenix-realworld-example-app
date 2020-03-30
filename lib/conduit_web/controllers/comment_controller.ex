defmodule ConduitWeb.CommentController do
  use ConduitWeb, :controller

  alias ConduitWeb.Guardian

  alias Conduit.Blog
  alias Conduit.Blog.Comment

  action_fallback ConduitWeb.FallbackController

  def action(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    # convert article_slug to slug, keep code consistent
    %{"article_slug" => slug} = params = conn.params
    params = params |> Map.put("slug", slug) |> Map.drop(["article_slug"])

    args = [conn, params, user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, params, current_user) do
    comments = Blog.list_article_comments(current_user, params)
    render(conn, "index.json", comments: comments)
  end

  def create(conn, %{"slug" => slug, "comment" => comment_params}, current_user) do
    with {:ok, %Comment{} = comment} <-
           Blog.create_user_comment(current_user, slug, comment_params) do
      conn
      |> put_status(:created)
      |> render("show.json", comment: comment)
    end
  end

  def delete(conn, %{"slug" => slug, "id" => id}, current_user) do
    comment = Blog.get_comment!(current_user, slug, id)

    with {:ok, %Comment{}} <- Blog.delete_comment(comment) do
      send_resp(conn, :no_content, "")
    end
  end
end
