defmodule Conduit.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Conduit.Repo

  alias Conduit.Blog.Tag

  def list_tags do
    Repo.all(Tag)
  end

  def get_or_insert_tags([]) do
    []
  end

  def get_or_insert_tags(names) do
    utc_now = DateTime.truncate(DateTime.utc_now(), :second)

    # insert_all 需要手动生成timestamp
    maps =
      Enum.map(
        names,
        &%{name: &1, updated_at: utc_now, created_at: utc_now}
      )

    Repo.insert_all(Tag, maps, on_conflict: :nothing)
    Repo.all(from t in Tag, where: t.name in ^names)
  end
end
