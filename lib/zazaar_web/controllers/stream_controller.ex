defmodule ZaZaarWeb.StreamController do
  use ZaZaarWeb, :controller

  def index(conn, _params) do
    with page <- current_page(conn),
         videos <- fetch_and_get_videos(:default, page) do
      render(conn, "index.html", videos: videos)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end

  defp fetch_and_get_videos(:default, page) do
    with {:ok, fb_vids} <- Fb.fetch_videos(page),
         db_vids <- Fb.get_videos(page),
         vids <- (fb_vids ++ db_vids) |> Enum.uniq() do
      Enum.sort_by(vids, & &1.creation_time)
    end
  end
end
