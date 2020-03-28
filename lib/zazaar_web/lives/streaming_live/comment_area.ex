defmodule ZaZaarWeb.StreamingLive.CommentArea do
  use Phoenix.LiveView, container: {:div, class: "tile is-parent is-4 streaming__comments"}

  alias ZaZaar.Account
  alias ZaZaarWeb.StreamView

  def render(assigns), do: StreamView.render("comment_area.html", assigns)

  def mount(_, session, socket) do
    %{"video_id" => video_id, "page_id" => page_id} = session |> IO.inspect(label: "sess")

    assigns =
      Map.merge(session, %{
        comments: [],
        page: Account.get_page(page_id),
        textarea: nil
      })
      |> Enum.into([])

    send(self(), {:mounted, video_id})

    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, video_id}, socket) do
    comments = Transcript.get_comments(video_id: video_id)

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_info({:new_comment, new_comment}, socket) do
    %{comments: comments, page: page, fb_video_id: fb_video_id} = socket.assigns

    comments_1 =
      case Fb.publish_comment(fb_video_id, new_comment, page.access_token) do
        {:ok, comment} ->
          comments ++ [comment]

        _ ->
          comments
      end

    {:noreply, assign(socket, comments: comments_1)}
  end

  def handle_event("new_comment", %{"comment" => comment0}, socket) do
    %{comments: comments, page: page, fb_video_id: fb_video_id} = socket.assigns

    comments_1 =
      case Fb.publish_comment(fb_video_id, comment0, page.access_token) do
        {:ok, comment1} ->
          comments ++ [comment1]

        _ ->
          comments
      end

    assigns = %{comments: comments_1, textarea: ""}

    {:noreply, assign(socket, assigns)}
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
      has_snapshot: true,
      fb_video_id: socket.assigns.fb_video_id,
      object_id: raw_params["object-id"]
    }
  end
end
