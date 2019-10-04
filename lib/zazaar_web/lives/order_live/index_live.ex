defmodule ZaZaarWeb.OrderLive.IndexLive do
  use ZaZaarWeb, :live

  alias ZaZaarWeb.OrderView

  @default_assigns %{
    filter: %{
      buyer: "",
      time_range: "",
      states: nil
    },
    orders: []
  }

  def render(assigns), do: render(OrderView, "index_live.html", assigns)

  def mount(session, socket) do
    assigns = Map.merge(@default_assigns, session)
    send(self(), {:mounted, assigns.page_id})
    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, page_id}, socket) do
    orders = Booking.get_orders([page_id: page_id], preload: :buyer)
    {:noreply, assign(socket, :orders, orders)}
  end
end
