defmodule ZaZaarWeb.PageController do
  use ZaZaarWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
