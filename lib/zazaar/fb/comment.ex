defmodule ZaZaar.Fb.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    # Comment Info
    field :message, :string
    field :creation_time, :naive_datetime
    field :object_id, :string

    # Commenter Info
    field :commenter_fb_id, :string
    field :commenter_name, :string
  end
end
