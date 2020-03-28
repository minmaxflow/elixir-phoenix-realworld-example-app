defimpl Phoenix.Param, for: Conduit.Blog.Article do
  alias Conduit.Blog.Article

  def to_param(%{slug: slug, title: title}) do
    "#{Article.slugify_title(title)}-#{slug}"
  end
end
