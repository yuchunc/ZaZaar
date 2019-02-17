defmodule ZaZaar.Booking.Item do
  use ZaZaar, :schema

  @type t :: %__MODULE__{
          merchandise_id: String.t(),
          title: String.t(),
          price: integer,
          status: OrderItemStatus.__enum_map__()
        }

  embedded_schema do
    field :merchandise_id, :string, null: false
    field :title, :string, null: false
    field :price, :integer, null: false
    field :status, OrderItemStatus
  end
end
