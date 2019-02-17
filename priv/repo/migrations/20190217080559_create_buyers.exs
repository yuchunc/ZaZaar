defmodule ZaZaar.Repo.Migrations.CreateBuyers do
  use Ecto.Migration

  def change do
    create table(:buyers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fb_name, :string
      add :fb_id, :string
      add :page_id, references(:pages, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:buyers, [:page_id])
  end
end
