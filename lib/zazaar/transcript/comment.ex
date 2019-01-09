defmodule ZaZaar.Transcript.Comment do
  use ZaZaar, :schema

  @primary_key false
  embedded_schema do
    # Comment Info
    field :object_id, :string, primary_key: true
    field :message, :string
    field :created_time, :naive_datetime

    # Toplevel comment ID
    field :parent_object_id, :string

    # Commenter Info
    field :commenter_fb_id, :string
    field :commenter_picture, :string
    field :commenter_fb_name, :string

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
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
