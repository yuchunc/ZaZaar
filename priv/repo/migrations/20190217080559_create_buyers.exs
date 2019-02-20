defmodule ZaZaar.Repo.Migrations.CreateBuyers do
  use Ecto.Migration

  def change do
    create table(:buyers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fb_name, :string
      add :fb_id, :string, null: false
      add :page_id, :string, null: false
    end

    create unique_index(:buyers, [:page_id, :fb_id])
  end
end
