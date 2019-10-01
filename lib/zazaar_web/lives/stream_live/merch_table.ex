defmodule ZaZaarWeb.StreamLive.MerchTable do
  use ZaZaarWeb, :live

  @default_assign %{
    show_snapshot_modal: false,
    snapshot_modal_url: "",
    merchs: []
  }

  def render(assigns), do: render(ZaZaarWeb.StreamView, "merch_table.html", assigns)

  def mount(session, socket) do
    video = Transcript.get_video(session.video_id)

    assigns =
      Map.merge(session, @default_assign)
      |> Map.put(:video, video)

    send(self(), {:mounted, video.id})
    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, vid_id}, socket) do
    merchs =
      Transcript.get_merchandises(vid_id,
        order_by: [desc: :inserted_at, desc_nulls_first: :invalidated_at]
      )

    {:noreply, assign(socket, :merchs, merchs)}
  end

  def handle_event("toggle-snapshot-modal", %{"snapshot" => snapshot_url}, socket) do
    assigns = %{
      show_snapshot_modal: !socket.assigns.show_snapshot_modal,
      snapshot_modal_url: snapshot_url
    }

    {:noreply, assign(socket, assigns)}
  end
end
