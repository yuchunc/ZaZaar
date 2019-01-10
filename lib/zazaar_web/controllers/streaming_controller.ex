defmodule ZaZaarWeb.StreamingController do
  use ZaZaarWeb, :controller

  def show(conn, _) do
    [video] = Transcript.get_videos(fb_status: :live)
    render(conn, "show.html", video: video)
  end
end
