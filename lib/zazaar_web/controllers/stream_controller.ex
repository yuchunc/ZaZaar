defmodule ZaZaarWeb.StreamController do
  use ZaZaarWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show do
  end
end
