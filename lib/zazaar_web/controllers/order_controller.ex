defmodule ZaZaarWeb.OrderController do
  use ZaZaarWeb, :controller

  def index(conn, _) do
    render conn, "index.html"
  end
end
