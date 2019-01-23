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
  alias ZaZaarWeb.StreamView

  onload(:page_loaded)

  defhandler comment_textbox_key(socket, sender) do
    do_comment_textarea_action(socket, sender["event"], String.trim(sender["value"]))
  end

  def page_loaded(socket) do
    %{assigns: %{drab_assigns: assigns}} = socket
    page = Account.get_page(assigns.page_id)
    Fb.start_subscribe(page)
  end

  defp do_comment_textarea_action(socket, %{"keyCode" => 13, "shiftKey" => false}, value)
       when value != "" do
    %{page: page, video: video} = load_socket_resources(socket)
    {:ok, comment} = Fb.publish_comment(video.fb_video_id, value, page.access_token)

    {:ok, comments} = peek(socket, :comments)
    poke(socket, comments: comments ++ [comment])
    set_prop!(socket, "#comment-input", value: "")
    exec_js(socket, "window.commentsListDom.scrollTop = window.commentsListDom.scrollHeight")
  end

  defp do_comment_textarea_action(_, _, _), do: nil

  defp load_socket_resources(socket) do
    %{assigns: %{drab_assigns: assigns}} = socket
    page = Account.get_page(assigns.page_id)
    video = Transcript.get_video(assigns.video_id)
    %{assigns: assigns, page: page, video: video}
  end
end
