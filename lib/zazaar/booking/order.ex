defmodule ZaZaar.Booking.Order do
  use Ecto.Schema

  import Ecto.Changeset

  alias ZaZaar.Booking

  @type t :: %__MODULE__{
          title: :string,
          total_amount: :pos_integer,
          page_id: :string,
          video_id: :string,
          buyer_id: :string,
          items: [Booking.Item]
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :title, :string
    field :total_amount, :integer, null: false
    field :page_id, :string
    field :video_id, Ecto.UUID
    field :notified_at, :naive_datetime
    field :void_at, :naive_datetime

    belongs_to :buyer, Booking.Buyer

    embeds_many :items, Booking.Item, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:title, :total_amount, :notified_at, :void_at])
    |> cast_embed(:items)
    |> validate_required([:title, :total_amount, :page_id, :video_id])
    |> assoc_constraint(:buyer)
  end
end