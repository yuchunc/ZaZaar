defmodule ZaZaarWeb.OrderController do
  use ZaZaarWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end
end
