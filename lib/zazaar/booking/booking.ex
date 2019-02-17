defmodule ZaZaar.Booking do
  use ZaZaar, :context

  alias ZaZaar.Booking
  alias Booking.Order

  alias ZaZaar.Transcript
  alias Transcript.Merchandise, as: Merch

  @doc """
  Creates a list of orders from merchs,
  one order per video perperson
  """
  @spec create_orders([Merch.t()]) :: [Order.t()]
  def create_orders([]), do: []

  def create_orders(merchs) do
  end
end
