defmodule ZaZaar.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :embed_html, :text, null: false
      add :fb_status, :string, null: false
      add :permalink_url, :string, null: false
      add :creation_time, :naive_datetime, null: false
      add :description, :text
      add :title, :string
      add :image_url, :text
      add :fb_video_id, :string, null: false
      add :fb_page_id, :string, null: false
      add :completed_at, :naive_datetime

      timestamps()
    end

    create index(:videos, [:fb_page_id])

    create unique_index(:videos, [:fb_video_id])
  end
end
