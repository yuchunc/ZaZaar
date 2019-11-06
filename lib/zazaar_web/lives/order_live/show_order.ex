defmodule ZaZaarWeb.OrderLive.ShowOrder do
  use ZaZaarWeb, :live

  @default_state %{
    adding_item: true,
    order: nil,
    video: nil
  }

  def render(assigns), do: render(ZaZaarWeb.OrderView, "show_order.html", assigns)

  def mount(session, socket) do
    %{order_id: order_id} = session

    [order] =
      [id: order_id]
      |> Booking.get_orders(preload: :buyer)

    assigns =
      @default_state
      |> Map.merge(%{order: order, video: Transcript.get_video(order.video_id)})

    {:ok, assign(socket, assigns)}
  end

  def handle_event("toggle-add", _, socket) do
    {:noreply, assign(socket, :adding_item, !socket.assigns.adding_item)}
  end
end
