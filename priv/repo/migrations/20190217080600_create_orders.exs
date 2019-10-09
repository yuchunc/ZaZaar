defmodule ZaZaar.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :total_amount, :integer, null: false
      add :page_id, references(:pages, type: :binary_id), null: false
      add :buyer_id, references(:buyers, type: :binary_id), null: false
      add :video_id, references(:videos, type: :binary_id), null: false
      add :items, {:array, :map}
      add :notified_at, :naive_datetime
      add :void_at, :naive_datetime

      timestamps()
    end

    create index(:orders, [:page_id])
    create index(:orders, [:buyer_id])
    create index(:orders, [:video_id])
    create unique_index(:orders, [:video_id, :buyer_id])
  end
end
