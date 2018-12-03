defmodule ZaZaarWeb.PageController do
  use ZaZaarWeb, :controller

  def index(conn, _attr) do
    render(conn, "index.html")
  end

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
