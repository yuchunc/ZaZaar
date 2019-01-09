defmodule ZaZaar.Transcript.Merchandise do
  use ZaZaar, :schema

  alias ZaZaar.Transcript

  @type t :: %__MODULE__{
          buyer_fb_id: String.t(),
          buyer_name: String.t(),
          price: integer,
          snapshot_url: String.t(),
          title: String.t(),
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

    belongs_to :video, Transcript.Video

    timestamps()
  end

  @doc false
  def changeset(merchandise, attrs) do
    merchandise
    |> cast(attrs, [:title, :snapshot_url, :price, :buyer_name, :buyer_fb_id])
    |> validate_required([:price])
  end
end
