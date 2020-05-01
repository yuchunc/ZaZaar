defmodule ZaZaarWeb.InvoiceController do
  use ZaZaarWeb, :controller

  alias ZaZaarWeb.OrderView

  def show(conn, %{"id" => id}) do
    with [order] = Booking.get_orders([id: id], preload: :buyer),
         video <- Transcript.get_video(order.video_id) do
      render(conn, "show.html", order: order, video: video)
    end
  end
end
