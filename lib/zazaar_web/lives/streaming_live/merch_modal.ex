defmodule ZaZaarWeb.StreamingLive.MerchModal do
  use ZaZaarWeb, :live

  @default_state %{
      show_modal: false,
      has_snapshot: true,
      snapshot_url: nil,
      commenter_fb_name: "",
      message: "",
      title: nil,
      price: nil
    }

  def render(assigns), do: render(ZaZaarWeb.StreamView, "merch_modal.html", assigns)

  def mount(session, socket) do
    %{fb_video_id: fb_video_id} = session

    if connected?(socket) do
      Phoenix.PubSub.subscribe(ZaZaar.PubSub, "stream:#{fb_video_id}")
    end

    send(self(), {:mounted, session})

    {:ok, assign(socket, @default_state)}
  end

  def handle_info({:mounted, session}, socket) do
    %{page_id: page_id} = session
    page = Account.get_page(page_id)

    {:noreply, assign(socket, :access_token, page.access_token)}
  end

  def handle_info(%{action: :new_merch} = payload, socket) do
    %{object_id: object_id, fb_video_id: fb_video_id} = payload
    %{assigns: %{access_token: access_token}} = socket

    today = Date.utc_today # NOTE this might need to take user tz
    comment = Transcript.get_comment(object_id)
    {:ok, %{"data" => thumbnails}} = Fb.video_thumbnails(fb_video_id, access_token)
    [vid_count] = Transcript.get_videos([fb_video_id: fb_video_id], get_count: true, on_date: today)

    assigns = %{
      show_modal: true,
      has_snapshot: true,
      snapshot_url: thumbnails,
      commenter_fb_name: comment.commenter_fb_name,
      message: comment.message,
      title: "#{inspect(today)} #{vid_count}" #{merch_count}"
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
