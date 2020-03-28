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
      String.slice(slug, -12..-1)
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
end
