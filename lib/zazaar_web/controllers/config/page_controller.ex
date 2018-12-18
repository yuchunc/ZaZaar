defmodule ZaZaarWeb.Config.PageController do
  use ZaZaarWeb, :controller

  plug :put_view, ZaZaarWeb.ConfigView

  def show(conn, _) do
    render(conn, "pages.html")
  end

  def update(conn, _) do
    redirect(conn, to: "/m")
  end
end
