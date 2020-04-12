defmodule ZaZaarWeb.StreamView do
  use ZaZaarWeb, :view

  def video_display_name(%Video{} = vid) do
    vid.title || vid.creation_time |> to_string
  end
end
