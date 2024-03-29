defmodule ZaZaar.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :image_url, :string
      add :fb_id, :string
      add :fb_access_token, :string

      timestamps()
    end

    create index(:users, [:fb_id])
  end
end
