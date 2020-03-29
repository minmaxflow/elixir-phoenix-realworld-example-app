defmodule Conduit.Repo.Migrations.CreateFavorites do
  use Ecto.Migration

  def change do
    create table(:favorites, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all, primary_key: true)
      add :article_id, references(:articles, on_delete: :delete_all, primary_key: true)

      timestamps()
    end

    create unique_index(:favorites, [:user_id, :article_id])
    create index(:favorites, [:article_id])
  end
end
