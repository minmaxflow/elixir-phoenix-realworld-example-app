defmodule Conduit.Repo.Migrations.RelatedTagToArticles do
  use Ecto.Migration

  def change do
    create table(:articles_tags, primary_key: false) do
      add :article_id, references(:articles, on_delete: :delete_all, primary_key: true)
      add :tag_id, references(:tags, on_delete: :delete_all, primary_key: true)
    end
  end
end
