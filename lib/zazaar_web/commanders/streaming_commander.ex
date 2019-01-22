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

  def page_loaded(socket) do
    %{drab_assigns: %{video_id: video_id}} = socket.assigns
    video = Transcript.get_video(video_id)

    comment_medias =
      video.comments
      |> Enum.map(fn c ->
        render_to_string(StreamView, "comment.html", comment: c)
      end)
      |> Enum.join("\n")

    set_prop!(socket, "#streaming-comments-list", innerHTML: comment_medias)
  end
end
