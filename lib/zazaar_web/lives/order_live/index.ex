defmodule ZaZaarWeb.OrderLive.Index do
  use ZaZaarWeb, :live

  alias ZaZaarWeb.OrderView

  @default_assigns %{
    filters: %{
      buyer: "",
      date_range: "",
      states: []
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

  def handle_event("clear-filters", _, socket) do
    %{page_id: page_id} = socket.assigns

    assigns = %{
      filters: @default_assigns.filters,
      orders: Booking.get_orders([page_id: page_id], preload: :buyer)
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("toggle-void", params, socket) do
    %{"order-id" => order_id} = params
    %{orders: orders0} = socket.assigns

    orders1 =
      Enum.map(orders0, fn
        %{id: ^order_id, void_at: nil} = order ->
          {:ok, order} =
            Booking.save_order(order, %{
              void_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
            })

          order

        %{id: ^order_id} = order ->
          {:ok, order} = Booking.save_order(order, %{void_at: nil})
          order

        order ->
          order
      end)

    {:noreply, assign(socket, :orders, orders1)}
  end

  defp get_orders_by_filters(page_id, filters) do
    [page_id: page_id, buyer_name: filters.buyer, date_range: filters.date_range]
    |> state_filters(filters.states)
    |> Booking.get_orders(preload: :buyer)
  end

  defp state_filters(list, []), do: list

  defp state_filters(list, [state | t]) do
    case state do
      "invalidated" -> state_filters([{:void_at, true} | list], t)
      "notified" -> state_filters([{:notified_at, true} | list], t)
    end
  end

  defp cast_filters(current, raw) do
    states =
      Map.get(raw, "states", [])
      |> Enum.map(&elem(&1, 0))

    %{
      buyer: raw["buyer"] || current.buyer,
      date_range: raw["date_range"] || current.date_range,
      states: states
    }
  end
end
