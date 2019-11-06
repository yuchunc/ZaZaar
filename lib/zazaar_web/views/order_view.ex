defmodule ZaZaarWeb.OrderView do
  use ZaZaarWeb, :view

  import Phoenix.LiveView

  def is_selected(range, range), do: {:safe, "selected"}
  def is_selected(_, _), do: nil

  def delimit(integer) do
    integer
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end
end
