defmodule ConduitWeb.ArticleView do
  use ConduitWeb, :view

  alias ConduitWeb.ArticleView
  alias ConduitWeb.TagView
  alias ConduitWeb.ProfileView
  alias Conduit.Blog.Article

  def render("index.json", %{articles: articles}) do
    %{articles: render_many(articles, ArticleView, "article.json")}
  end

  def render("show.json", %{article: article}) do
    %{article: render_one(article, ArticleView, "article.json")}
  end

  def render("article.json", %{article: article}) do
    %{
      id: article.id,
      title: article.title,
      slug: Article.slugify_title(article.title) <> "-" <> article.slug,
      description: article.description,
      body: article.body,
      createdAt: DateTime.to_iso8601(article.created_at),
      updatedAt: DateTime.to_iso8601(article.updated_at),
      tagList: render_many(article.tags, TagView, "tag.json"),
      favorited: article.favorited,
      favoritesCount: article.favorites_count,
      author: render_one(article.author, ProfileView, "profile.json")
    }
  end
end
