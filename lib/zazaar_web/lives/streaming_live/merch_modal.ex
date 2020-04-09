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

  def mount(_, session, socket) do
    %{"video_id" => video_id} = session

    send(self(), {:mounted, session})
    Phoenix.PubSub.subscribe(ZaZaar.PubSub, "stream:#{video_id}")

    assigns = Map.merge(@default_state, %{video_id: video_id})

    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, session}, socket) do
    %{"page_id" => page_id} = session

    assigns = %{
      access_token: Account.get_page(page_id) |> Map.get(:access_token)
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_info(%{action: :new_merch} = payload, socket) do
    %{object_id: object_id, fb_video_id: fb_video_id, has_snapshot: has_snapshot} = payload
    %{access_token: access_token, video_id: vid_id} = socket.assigns

    # NOTE this might need to take user tz
    today = Date.utc_today()
    comment = Transcript.get_comment(object_id)
    [vid_count] = Transcript.get_videos([], get_count: true, on_date: today)

    [merch_count] =
      case Transcript.get_merchandises([video_id: vid_id], get_count: true) do
        [] -> [0]
        result -> result
      end

    price =
      case Regex.run(~r/\d+/, comment.message) do
        [value] -> value
        _ -> nil
      end

    assigns0 = %{
      show_modal: true,
      has_snapshot: has_snapshot,
      snapshot_url: "",
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

    assigns1 =
      if has_snapshot do
        {:ok, %{"data" => thumbnails}} = Fb.video_thumbnails(fb_video_id, access_token)
        snapshot_url = thumbnails |> List.last() |> Map.get("uri")
        %{assigns0 | snapshot_url: snapshot_url}
      else
        assigns0
      end

    {:noreply, assign(socket, assigns1)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def handle_event("save-merch", params, socket) do
    %{
      snapshot_url: snapshot_url,
      video_id: video_id,
      commenter_fb_name: com_fb_name,
      commenter_fb_id: com_fb_id
    } = socket.assigns

    merch_attrs = %{
      title: params["title"],
      price: params["price"],
      snapshot_url: snapshot_url,
      video_id: video_id,
      buyer_name: com_fb_name,
      buyer_fb_id: com_fb_id
    }

    case Transcript.save_merchandise(merch_attrs) do
      {:ok, merch} ->
        payload = %{action: :save_merch, merch_id: merch.id}
        Phoenix.PubSub.broadcast(ZaZaar.PubSub, "stream:#{video_id}", payload)
        {:noreply, assign(socket, @default_state)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("close-modal", _, socket), do: {:noreply, assign(socket, @default_state)}
end
