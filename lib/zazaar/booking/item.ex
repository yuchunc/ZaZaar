defmodule ZaZaar.Booking.Item do
  @moduledoc """
  need to add image url
  """
  use ZaZaar, :schema

  @type t :: %__MODULE__{
          merchandise_id: String.t(),
          title: String.t(),
          price: integer,
          status: OrderItemStatus.__enum_map__(),
          snapshot_url: nil | String.t()
        }

  embedded_schema do
    field :merchandise_id, :string, null: false
    field :title, :string, null: false
    field :price, :integer, null: false
    field :snapshot_url, :string
    field :status, OrderItemStatus
  end

  def changeset(item, %__MODULE__{}), do: cast(item, %{}, [])

  def changeset(item, params) do
    item
    |> cast(params, [:merchandise_id, :title, :price, :snapshot_url, :status])
    |> validate_required([:merchandise_id, :title, :price, :status])
  end
end
