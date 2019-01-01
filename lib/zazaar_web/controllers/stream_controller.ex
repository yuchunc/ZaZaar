defmodule ZaZaarWeb.StreamController do
  use ZaZaarWeb, :controller

  def index(conn, _params) do
    with page <- current_page(conn),
         videos <- fetch_and_get_videos(:default, page) do
      render(conn, "index.html", videos: videos, first_video: first_video(videos))
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end

  # TODO
  # default option
  # pagination option
  # fetch all option
  defp fetch_and_get_videos(:default, page) do
    with {:ok, _fb_vids} <- Fb.fetch_videos(page),
         db_vids <- Fb.get_videos(page, order_by: [asc: :fb_status]) do
      db_vids
    end
  end

  defp first_video([]), do: %Video{}
  defp first_video(videos), do: List.first(videos)
end
