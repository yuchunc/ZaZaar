defmodule ZaZaar.Booking.Buyer do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          fb_id: String.t(),
          fb_name: String.t(),
          page_id: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "buyers" do
    field :fb_id, :string
    field :fb_name, :string
    field :page_id, :string
  end

  @doc false
  def changeset(buyer, attrs) do
    buyer
    |> cast(attrs, [:fb_name, :fb_id])
    |> validate_required([:fb_name, :fb_id, :page_id])
  end
end
