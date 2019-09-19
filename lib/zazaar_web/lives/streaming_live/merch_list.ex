defmodule ZaZaarWeb.StreamingLive.MerchList do
  use ZaZaarWeb, :live

  def render(assigns), do: render(ZaZaarWeb.StreamingView, "merch_list.html", assigns)

  def mount(session, socket) do
    %{video_id: video_id} = session
    merchs = Transcript.get_merchandises(video_id, order_by: [desc: :inserted_at])
    {:ok, assign(socket, :merchs, merchs)}
  end
end
