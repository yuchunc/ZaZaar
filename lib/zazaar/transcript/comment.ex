defmodule ZaZaar.Transcript.Comment do
  use ZaZaar, :schema

  alias ZaZaar.Transcript

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "comments" do
    # Comment Info
    field :object_id, :string
    field :message, :string
    field :created_time, :naive_datetime
    field :live_timestamp, :integer, default: 0

    # Toplevel comment ID
    # it is the parent field on Facebook Graph
    field :parent_object_id, :string

    # Commenter Info
    field :commenter_fb_id, :string
    field :commenter_picture, :string
    field :commenter_fb_name, :string

    belongs_to :video, Transcript.Video, type: :binary_id

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :live_timestamp,
      :message,
      :created_time,
      :object_id,
      :parent_object_id,
      :commenter_fb_id,
      :commenter_picture,
      :commenter_fb_name
    ])
    |> validate_required([
      :created_time,
      :object_id,
      :commenter_fb_id,
      :commenter_fb_name
    ])
  end
end
