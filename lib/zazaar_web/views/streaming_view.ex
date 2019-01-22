defmodule ZaZaarWeb.StreamingView do
  use ZaZaarWeb, :view

  def custom_js(conn) do
    if action_name(conn) == :show do
      render(__MODULE__, "drab_configs.html", conn: conn, video_id: conn.assigns.video_id)
    end
  end
end
