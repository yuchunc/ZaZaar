defmodule ZaZaar.Repo.Migrations.CreateBuyers do
  use Ecto.Migration

  def change do
    create table(:buyers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fb_name, :string
      add :fb_id, :string

      add :page_id, :uuid, null: false

      timestamps()
    end

    create unique_index(:buyers, [:page_id, :fb_id])
  end
end
