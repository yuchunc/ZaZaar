defmodule ZaZaarWeb.StreamLive.CommentArea do
  use ZaZaarWeb, :live

  @default_state %{
    video_id: nil,
    comments: []
  }

  def render(assigns), do: render(ZaZaarWeb.StreamView, "comment_area.html", assigns)

  def mount(_, session, socket) do
    %{"video_id" => video_id, "is_completed" => completed} = session

    assigns = Map.merge(@default_state, %{video_id: video_id, is_completed: completed})

    send(self(), {:mounted, assigns.video_id})

    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, video_id}, socket) do
    {:noreply, assign(socket, :comments, Transcript.get_comments(video_id: video_id))}
  end

  def handle_event("enable-merch-modal", params, socket) do
    payload = cast_new_merch(params, socket)
    %{video_id: video_id} = socket.assigns
    Phoenix.PubSub.broadcast(ZaZaar.PubSub, "stream:#{video_id}", payload)
    {:noreply, socket}
  end

  defp cast_new_merch(raw_params, socket) do
    %{
      source: __MODULE__,
      action: :new_merch,
      has_snapshot: false,
      fb_video_id: socket.assigns.fb_video_id,
      object_id: raw_params["object-id"]
    }
  end
end
