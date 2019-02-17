defmodule ZaZaar.Transcript.Merchandise do
  @moduledoc """
  TODO Need to add page id reference to this schema
  """
  use ZaZaar, :schema

  alias ZaZaar.Transcript

  @type t :: %__MODULE__{
          buyer_fb_id: String.t(),
          buyer_name: String.t(),
          price: integer,
          snapshot_url: String.t(),
          title: String.t(),
          invalidated_at: nil | NaiveDateTime.t(),
          video_id: Ecto.UUID.t(),
          video: Transcript.Video.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "merchandises" do
    field :buyer_fb_id, :string
    field :buyer_name, :string
    field :price, :integer
    field :snapshot_url, :string
    field :title, :string
    field :invalidated_at, :naive_datetime

    belongs_to :video, Transcript.Video

    timestamps()
  end

  @doc false
  def changeset(merchandise, attrs) do
    merchandise
    |> cast(attrs, [:title, :snapshot_url, :price, :invalidated_at])
    |> validate_required([:price, :buyer_fb_id, :buyer_name])
    |> assoc_constraint(:video)
  end
end
