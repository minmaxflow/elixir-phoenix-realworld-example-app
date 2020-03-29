defmodule ConduitWeb.ArticleController do
  use ConduitWeb, :controller

  alias ConduitWeb.Guardian

  alias Conduit.Blog
  alias Conduit.Blog.Article

  action_fallback ConduitWeb.FallbackController

  def action(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    args = [conn, conn.params, user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, params, current_user) do
    articles = Blog.list_articles(current_user, params)
    render(conn, "index.json", articles: articles)
  end

  def feed(conn, params, current_user) do
    articles = Blog.list_feed_articles(current_user, params)
    render(conn, "index.json", articles: articles)
  end

  def show(conn, %{"slug" => slug}, current_user) do
    # 注意，这个不需要scope to curent_user  
    article = Blog.get_article_by_slug!(current_user, slug)
    render(conn, "show.json", article: article)
  end

  def create(conn, %{"article" => article_params}, current_user) do
    with {:ok, %Article{} = article} <- Blog.create_article(current_user, article_params) do
      # 重新获取一遍
      article = Blog.get_article_by_slug!(current_user, article.slug)

      conn
      |> put_status(:created)
      |> render("show.json", article: article)
    end
  end

  def update(conn, %{"slug" => slug, "article" => article_params}, current_user) do
    article = Blog.get_user_article_by_slug!(current_user, slug)

    with {:ok, %Article{} = article} <- Blog.update_article(article, article_params) do
      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}, current_user) do
    article = Blog.get_user_article_by_slug!(current_user, slug)

    with {:ok, %Article{}} <- Blog.delete_article(article) do
      send_resp(conn, :no_content, "")
    end
  end

  def favorite(conn, %{"slug" => slug}, current_user) do
    with {:ok, _} <- Blog.favorite_article(current_user, slug) do
      article = Blog.get_article_by_slug!(current_user, slug)
      render(conn, "show.json", article: article)
    end
  end

  def unfavorite(conn, %{"slug" => slug}, current_user) do
    with {:ok, _} <- Blog.unfavorite_article(current_user, slug) do
      article = Blog.get_article_by_slug!(current_user, slug)
      render(conn, "show.json", article: article)
    end
  end
end
