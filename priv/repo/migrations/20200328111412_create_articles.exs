defmodule Conduit.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :string
      add :body, :text
      add :author_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:articles, [:slug])
    create index(:articles, [:author_id])
  end
end
