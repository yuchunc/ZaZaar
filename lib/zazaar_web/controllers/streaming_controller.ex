defmodule ZaZaarWeb.StreamingController do
  use ZaZaarWeb, :controller

  def show(conn, _) do
    video =
      conn
      |> get_session(:video_id)
      |> Transcript.get_video()

    case video do
      %{fb_status: :live} ->
        drab_assigns = %{
          user_token: current_user(conn, :token),
          page_id: current_page(conn) |> Map.get(:id),
          video_id: video.id
        }

        merchs = Transcript.get_merchandises(video)

        conn
        |> assign(:drab_assigns, drab_assigns)
        |> render("show.html",
          video: Map.delete(video, :comments),
          comments: video.comments,
          merchandises: merchs
        )

      %{fb_status: :vod} ->
        redirect(conn, to: "/s/" <> video.fb_video_id)

      _ ->
        {:error, :not_found}
    end
  end
end
