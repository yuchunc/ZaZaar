defmodule ZaZaarWeb.OrderLive.ShowOrder do
  use ZaZaarWeb, :live

  @default_state %{
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
end
