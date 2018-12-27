defmodule ZaZaarWeb.StreamController do
  use ZaZaarWeb, :controller

  # TODO
  # Probably add Fb Webhook to get update to the video list
  # Use Webhook per Page to update client frontend

  def index(conn, _params) do
    with page <- current_page(conn),
         videos0 <- Fb.get_videos(page) do
      {:ok, videos1} =
        case videos0 do
          [] -> Fb.fetch_videos(page)
          _ -> {:ok, videos0}
        end

      render(conn, "index.html", videos: videos1)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end
end
