defmodule ZaZaarWeb.StreamingView do
  use ZaZaarWeb, :view

  import Phoenix.LiveView

  def snapshot_url(%{snapshot_url: nil}), do: "https://bulma.io/images/placeholders/640x480.png"

  def snapshot_url(merch), do: merch.snapshot_url

  def invalidate_class(%{invalidated_at: %NaiveDateTime{}}), do: "is-invalidate"

  def invalidate_class(_), do: ""
end
