defmodule ZaZaarWeb.BatchOrderController do
  use ZaZaarWeb, :controller

  def create(conn, %{"video_id" => video_id}) do
    video = Transcript.get_video(video_id)
    merchs = Transcript.get_merchandises(video_id)
    page = current_page(conn)
    {:ok, _} = Booking.create_video_orders(video, merchs, page.id)
    Transcript.update_video(video, %{completed_at: NaiveDateTime.utc_now()})
    # TODO need to send created invoice url to buyers
    redirect(conn, to: "/o")
  end
end
