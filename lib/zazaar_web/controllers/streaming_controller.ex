defmodule ZaZaarWeb.StreamingController do
  use ZaZaarWeb, :controller

  def show(conn, _) do
    video =
      conn
      |> get_session(:video_id)
      |> Transcript.get_video()

    case video do
      %{fb_status: :live} ->
        conn
        |> assign(:drab_assigns, %{video_id: video.id})
        |> render("show.html", video: video)

      %{fb_status: :vod} ->
        redirect(conn, to: "/s/" <> video.fb_video_id)

      _ ->
        {:error, :not_found}
    end
  end
end
