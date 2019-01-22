defmodule ZaZaarWeb.StreamingView do
  use ZaZaarWeb, :view

  def custom_js(conn) do
    render(__MODULE__, "drab.html", conn: conn)
  end
end
