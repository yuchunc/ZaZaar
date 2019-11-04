defmodule ZaZaarWeb.OrderController do
  use ZaZaarWeb, :controller

  def index(conn, _) do
    page = current_page(conn)

    orders = Booking.get_orders([page_id: page.id], preload: :buyer)

    render(conn, "index.html", orders: orders)
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", order_id: id)
  end
end
