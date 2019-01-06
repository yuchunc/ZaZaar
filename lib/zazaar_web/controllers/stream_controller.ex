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

  def update(conn, %{"id" => fb_video_id}) do
    with %Video{} = video <- Transcript.get_video(fb_video_id),
         page <- current_page(conn),
         {:ok, _} <- Fb.fetch_comments(video, page.access_token) do
      redirect(conn, to: "/s/#{fb_video_id}")
    end
  end

  def show(conn, %{"id" => fb_video_id}) do
    video = %Video{} = Transcript.get_video(fb_video_id)
    render(conn, "show.html", video: video)
  end

  # TODO
  # pagination option
  defp fetch_and_get_videos("default", page), do: Fb.fetch_videos(page)
  defp fetch_and_get_videos("fetch_all", page), do: Fb.fetch_videos(page, strategy: :all)

  defp first_video([]), do: %Video{}
  defp first_video(videos), do: List.first(videos)
end
