defmodule ZaZaarWeb.StreamingController do
  use ZaZaarWeb, :controller

  def show(conn, _) do
    render(conn, "show.html")
  end
end
