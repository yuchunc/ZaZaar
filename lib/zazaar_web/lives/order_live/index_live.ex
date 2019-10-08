defmodule ZaZaarWeb.OrderLive.IndexLive do
  use ZaZaarWeb, :live

  alias ZaZaarWeb.OrderView

  @default_assigns %{
    filters: %{
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

  def handle_event("set-filters", params, socket) do
    %{"filters" => new_filters} = params

    %{filters: current_filters, page_id: page_id} = socket.assigns

    filters = cast_filters(current_filters, new_filters)

    assigns = %{
      filters: filters,
      orders: get_orders_by_filters(page_id, filters)
    }

    {:noreply, assign(socket, assigns)}
  end

  defp get_orders_by_filters(page_id, filters) do
    [page_id: page_id, buyer_name: filters.buyer, date_range: filters.time_range]
    |> Booking.get_orders(preload: :buyer)
  end

  defp cast_filters(current, raw) do
    states =
      Map.get(raw, "states", [])
      |> Enum.map(&elem(&1, 0))

    %{
      buyer: raw["buyer"] || current.buyer,
      time_range: raw["time_range"] || current.time_range,
      states: states
    }
  end
end
