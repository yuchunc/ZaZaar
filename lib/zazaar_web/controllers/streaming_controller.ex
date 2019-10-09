defmodule ZaZaarWeb.StreamingController do
  use ZaZaarWeb, :controller

  def show(conn, _) do
    video =
      conn
      |> get_session(:video_id)
      |> Transcript.get_video(preload: :comments)

    case video do
      %{fb_status: :live} ->
        conn
        |> render("show.html",
          video: Map.delete(video, :comments),
          page_id: current_page(conn) |> Map.get(:id)
        )

      %{fb_status: :vod} ->
        redirect(conn, to: "/s/" <> video.fb_video_id)

      _ ->
        {:error, :not_found}
    end
  end
end
