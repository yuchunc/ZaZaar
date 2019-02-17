defmodule ZaZaar.Booking.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias ZaZaar.Booking

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :title, :string
    field :total_amount, :integer, null: false
    field :page_id, :integer

    belongs_to :buyer, Booking.Buyer

    embeds_many :items, Booking.Item, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [])
    |> validate_required([:title, :total_amount, :page_id])
    |> assoc_constraint(:buyer)
  end
end
