defmodule ZaZaar.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fb_page_id, :string, null: false
      add :access_token, :string, null: false
      add :name, :string, null: false
      add :tasks, {:array, :jsonb}, null: false
      add :picture_url, :text

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:pages, [:user_id])
    create unique_index(:pages, [:user_id, :fb_page_id], name: :pages_user_id_fb_page_id_index)
  end
end
