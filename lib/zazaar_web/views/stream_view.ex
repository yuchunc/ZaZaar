defmodule ZaZaarWeb.StreamView do
  use ZaZaarWeb, :view

  import Phoenix.LiveView

  def video_display_name(%Video{} = vid) do
    vid.title || vid.creation_time |> to_string
  end

  def custom_js(conn) do
    if action_name(conn) == :show do
      render(StreamView, "drab_configs.html", conn: conn, video_id: conn.assigns.video_id)
    end
  end
end
