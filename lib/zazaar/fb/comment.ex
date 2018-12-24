defmodule ZaZaar.Fb.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    # Comment Info
    field :message, :string
    field :created_time, :naive_datetime
    field :object_id, :string

    # Toplevel comment ID
    field :parent_object_id, :string

    # Commenter Info
    field :commenter_fb_id, :string
    field :commenter_fb_name, :string

    timestamps
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :message,
      :created_time,
      :object_id,
      :parent_object_id,
      :commenter_fb_id,
      :commenter_fb_name
    ])
    |> validate_required([
      :message,
      :created_time,
      :object_id,
      :commenter_fb_id,
      :commenter_fb_name
    ])
  end
end
