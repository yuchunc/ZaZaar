defmodule ZaZaarWeb.StreamingView do
  use ZaZaarWeb, :view

  import Phoenix.LiveView

  alias ZaZaarWeb.StreamView

  def snapshot_url(%{snapshot_url: nil}), do: "https://bulma.io/images/placeholders/640x480.png"

  def snapshot_url(merch), do: merch.snapshot_url

  def invalidate_class(%{invalidated_at: %NaiveDateTime{}}), do: "is-invalidate"

  def invalidate_class(_), do: ""

  def custom_js(conn) do
    if action_name(conn) == :show do
      render(StreamView, "drab_configs.html", conn: conn, video_id: conn.assigns.video_id)
    end
  end
end
