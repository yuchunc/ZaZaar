defmodule ZaZaarWeb.StreamingLive do
  use ZaZaarWeb, :live

  alias ZaZaarWeb.StreamingView, as: View

  def render(assigns), do: View.render("show.html", assigns)

  def mount(session, socket) do
    %{video_id: video_id, page: page} = session

    video = Transcript.get_video(video_id)
    comments = video.comments

    merchs = Transcript.get_merchandises(video, order_by: [desc: :inserted_at])

    {:ok,
     assign(socket, %{
       page: page,
       video: Map.delete(video, :comments),
       comments: comments,
       merchandises: merchs
     })}
  end
end
