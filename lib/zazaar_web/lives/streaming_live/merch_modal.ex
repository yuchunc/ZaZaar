defmodule ZaZaarWeb.StreamingLive.MerchModal do
  use ZaZaarWeb, :live

  @default_state %{
    show_modal: false,
    has_snapshot: true,
    snapshot_url: nil,
    commenter_fb_name: nil,
    commenter_fb_id: nil,
    message: "",
    title: nil,
    price: nil,
    merch_id: nil
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
    %{page_id: page_id, fb_video_id: fb_video_id} = session

    assigns = %{
      access_token: Account.get_page(page_id) |> Map.get(:access_token),
      video_id: Transcript.get_video(fb_video_id) |> Map.get(:id)
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_info(%{action: :new_merch} = payload, socket) do
    %{object_id: object_id, fb_video_id: fb_video_id} = payload
    %{assigns: %{access_token: access_token, video_id: vid_id}} = socket

    # NOTE this might need to take user tz
    today = Date.utc_today()
    comment = Transcript.get_comment(object_id)
    {:ok, %{"data" => thumbnails}} = Fb.video_thumbnails(fb_video_id, access_token)
    [vid_count] = Transcript.get_videos([], get_count: true, on_date: today)

    [merch_count] =
      case Transcript.get_merchandises([video_id: vid_id], get_count: true) do
        [] -> [0]
        result -> result
      end

    [price] = Regex.run(~r/\d+/, comment.message)

    assigns = %{
      show_modal: true,
      has_snapshot: true,
      snapshot_url: thumbnails |> List.last() |> Map.get("uri"),
      commenter_fb_name: comment.commenter_fb_name,
      commenter_fb_id: comment.commenter_fb_id,
      message: comment.message,
      title:
        gettext("%{today} Stream #%{vid_count} Merchandise #%{merch_count}",
          today: today,
          vid_count: vid_count,
          merch_count: merch_count + 1
        ),
      price: price
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def handle_event("save-merch", params, socket) do
    assigns = socket.assigns

    merch_attrs = %{
      title: params["title"],
      price: params["price"],
      snapshot_url: assigns.snapshot_url,
      video_id: assigns.video_id,
      buyer_name: assigns.commenter_fb_name,
      buyer_fb_id: assigns.commenter_fb_id
    }

    case Transcript.save_merchandise(merch_attrs) do
      {:ok, _} -> {:noreply, assign(socket, @default_state)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("close-modal", _, socket), do: {:noreply, assign(socket, @default_state)}
end
