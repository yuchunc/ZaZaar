defmodule ZaZaarWeb.OrderView do
  use ZaZaarWeb, :view

  import Phoenix.LiveView

  def is_selected(range, range), do: {:safe, "selected"}
  def is_selected(_, _), do: nil
end
