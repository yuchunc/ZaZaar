defmodule ZaZaarWeb.PageController do
  use ZaZaarWeb, :controller

  def about(conn, _attr) do
    render(conn, "about.html")
  end

  def privacy(conn, _attr) do
    render(conn, "privacy.html")
  end

  def service(conn, _attr) do
    render(conn, "service.html")
  end
end
