defmodule ZaZaarWeb.StreamingCommander do
  use ZaZaarWeb, :commander

  alias ZaZaarWeb.StreamView

  onload(:page_loaded)

  defhandler comment_textbox_keydown(socket, sender) do
    do_comment_textarea_action(socket, sender["event"], String.trim(sender["value"]))
  end

  defhandler set_merchandise_modal(socket, _sender) do
    %{page: page, video: video} = load_socket_resources(socket)
    {:ok, %{"data" => thumbnails}} = Fb.video_thumbnails(video.fb_video_id, page.access_token)
    taipei_dt = Timex.now("Asia/Taipei") |> Timex.format!("%F %T", :strftime)

    unless thumbnails == [] do
      %{"uri" => uri} = _ = List.last(thumbnails)
      title = taipei_dt <> gettext(" Merchandise")

      exec_js(socket, """
        document.getElementById('merch-modal-img').src = '#{uri}';
        document.getElementById('merch-modal-snapshot-url').value = '#{uri}';
        document.getElementById('merch-modal-title').value = '#{title}';
      """)
    end
  end

  defhandler save_merchandise(socket, %{params: params}) do
    %{assigns: assigns} = load_socket_resources(socket)

    {:ok, merch} =
      params
      |> Map.put("video_id", assigns.video_id)
      |> map_merchandise
      |> Transcript.save_merchandise()

    {:ok, merchs} = peek(socket, :merchandises)
    poke(socket, merchandises: [merch | merchs])
    exec_js(socket, "closeNewMerchModal('newMerch')")
  end

  def page_loaded(socket) do
    %{assigns: %{drab_assigns: assigns}} = socket
    page = Account.get_page(assigns.page_id)
    Fb.start_subscribe(page)
  end

  defp do_comment_textarea_action(socket, %{"keyCode" => 13, "shiftKey" => false}, value)
       when value != "" do
    set_prop!(socket, "#comment-input", %{"attributes" => %{"disabled" => true}})
    %{page: page, video: video} = load_socket_resources(socket)
    {:ok, comment} = Fb.publish_comment(video.fb_video_id, value, page.access_token)

    comment_partial = render_to_string(StreamView, "comment.html", comment: comment)

    exec_js(socket, "appendCommentPanel(`#{comment_partial}`)")
    set_prop!(socket, "#comment-input", %{attributes: %{disabled: false}})
  end

  defp do_comment_textarea_action(_, _, _), do: nil

  defp load_socket_resources(socket) do
    %{assigns: %{drab_assigns: assigns}} = socket
    page = Account.get_page(assigns.page_id)
    video = Transcript.get_video(assigns.video_id)
    %{assigns: assigns, page: page, video: video}
  end

  defp map_merchandise(merch) do
    merch |> IO.inspect(label: "merch")

    %{
      id: merch["id"],
      video_id: merch["video_id"],
      buyer_fb_id: merch["buyer_fb_id"],
      buyer_name: merch["buyer_name"],
      price: merch["price"],
      title: merch["title"],
      invalidated_at: merch["invalidated_at"],
      snapshot_url: merch["snapshot_url"],
      live_timestamp: merch["live_broadcast_timestamp"]
    }
  end
end
