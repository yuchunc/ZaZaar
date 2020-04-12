defmodule ZaZaar.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :object_id, :string, null: false
      add :message, :string, null: false
      add :created_time, :naive_datetime
      add :live_timestamp, :integer, default: 0

      # it is the parent field on Facebook Graph
      add :parent_object_id, :string

      # Commenter Info
      add :commenter_fb_id, :string
      add :commenter_picture, :text
      add :commenter_fb_name, :string

      add :video_id, references("videos", type: :uuid), null: false

      timestamps()
    end
  end
end
