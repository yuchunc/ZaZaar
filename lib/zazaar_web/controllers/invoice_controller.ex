defmodule ZaZaarWeb.InvoiceController do
  use ZaZaarWeb, :controller

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end
end
