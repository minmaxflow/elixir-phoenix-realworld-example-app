defmodule Conduit.Blog.Permalink do
  @behaviour Ecto.Type

  def type, do: :string

  # cast from outside 
  def cast(slug) when is_binary(slug) do
    size = byte_size(slug)

    # title-slug(12)
    if size < 16 do
      :error
    else
      {:ok, String.slice(slug, -12..-1)}
    end
  end

  def cast(_) do
    :error
  end

  # Invoked when data is sent to the database.
  def dump(string) do
    {:ok, string}
  end

  # Invoked when data is loaded from the database.
  def load(string) do
    {:ok, string}
  end

  def equal?(term1, term2) when is_binary(term1) and is_binary(term2) do
    String.slice(term1, -12..-1) == String.slice(term2, -12..-1)
  end

  def equal?(term1, term2) do
    term1 === term2
  end

  def embed_as(_format) do
    :self
  end
end
