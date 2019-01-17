defmodule ZaZaar.Repo.Migrations.CreateMerchandises do
  use Ecto.Migration

  def change do
    create table(:merchandises, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :price, :integer, null: false
      add :snapshot_url, :string
      add :buyer_name, :string
      add :buyer_fb_id, :string
      add :invalidated_at, :naive_datetime

      add :video_id, references(:videos, type: :uuid), null: false

      timestamps()
    end

    create index(:merchandises, [:buyer_fb_id])
  end
end
