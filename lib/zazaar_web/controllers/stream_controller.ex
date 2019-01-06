defmodule ZaZaarWeb.StreamController do
  use ZaZaarWeb, :controller

  @doc """
  Stream Index

  takes the following params:
  "strategy" : `default`, `fetcht_all`
  """
  def index(conn, params) do
    with page <- current_page(conn),
         strategy <- Map.get(params, "strategy", "default"),
         {:ok, videos} <- fetch_and_get_videos(strategy, page) do
      render(conn, "index.html", videos: videos, first_video: first_video(videos))
    end
  end

  def show(conn, %{"id" => fb_video_id}) do
    render(conn, "show.html", id: fb_video_id)
  end

  # TODO
  # pagination option
  defp fetch_and_get_videos("default", page), do: Fb.fetch_videos(page)
  defp fetch_and_get_videos("fetch_all", page), do: Fb.fetch_videos(page, strategy: :all)

  defp first_video([]), do: %Video{}
  defp first_video(videos), do: List.first(videos)
end
