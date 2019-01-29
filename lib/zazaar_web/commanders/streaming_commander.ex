defmodule ZaZaarWeb.StreamingCommander do
  use ZaZaarWeb, :commander
  # Place your event handlers here
  #
  # defhandler button_clicked(socket, sender) do
  #   set_prop socket, "#output_div", innerHTML: "Clicked the button!"
  # end
  #
  # Place you callbacks here

  alias ZaZaar.Auth.Guardian
  alias ZaZaarWeb.{StreamView, StreamingView}

  onload(:page_loaded)

  defhandler comment_textbox_keydown(socket, sender) do
    do_comment_textarea_action(socket, sender["event"], String.trim(sender["value"]))
  end

  defhandler new_merchandise(socket, sender, comment_str) do
    %{page: page, video: video} = load_socket_resources(socket)
    {:ok, comment_map} = Jason.decode(comment_str)
    {:ok, %{"data" => thumbnails}} = Fb.video_thumbnails(video.fb_video_id, page.access_token)
    taipei_dt = Timex.now("Asia/Taipei") |> Timex.format!("%F %T", :strftime)

    snapshot_url =
      if thumbnails == [] do
        nil
      else
        %{"uri" => uri} = _ = List.last(thumbnails)
        uri
      end

    # comment to merchandise
    payload = %{
      buyer_fb_id: comment_map["commenter_fb_id"],
      buyer_name: comment_map["commenter_fb_name"],
      title: taipei_dt <> gettext(" Merchandise"),
      price: Regex.run(~r/\d+/, comment_map["message"]) |> List.first(),
      snapshot_url: snapshot_url,
      message: comment_map["message"]
    }

    exec_js(socket, "newMerchandiseModal(`#{Jason.encode!(payload)}`)")
  end

  defhandler save_merchandise(socket, sender) do
    sender |> IO.inspect(label: "sender")
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

    comment_partial =
      render_to_string(StreamView, "comment.html", comment: comment)
      |> IO.inspect(label: "label")

    js_funciton =
      """
        commentsListDom.appendChild(el('#{comment_partial}'));
        document.getElementById("comment-input").value = "";
        if (commentsListDom.scrollTop >= commentsListDom.scrollHeight - 800) {
         commentsListDom.scrollTop = commentsListDom.scrollHeight;
        }
      """
      |> String.replace("\n", "")

    exec_js(socket, js_funciton)
    set_prop!(socket, "#comment-input", %{attributes: %{disabled: false}})
  end

  defp do_comment_textarea_action(_, _, _), do: nil

  defp load_socket_resources(socket) do
    %{assigns: %{drab_assigns: assigns}} = socket
    page = Account.get_page(assigns.page_id)
    video = Transcript.get_video(assigns.video_id)
    %{assigns: assigns, page: page, video: video}
  end
end
