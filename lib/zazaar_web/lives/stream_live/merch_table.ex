defmodule ZaZaarWeb.StreamLive.MerchTable do
  use ZaZaarWeb, :live

  @default_assign %{
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
    Phoenix.PubSub.subscribe(ZaZaar.PubSub, "stream:#{video.id}")

    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, vid_id}, socket) do
    merchs =
      Transcript.get_merchandises(vid_id,
        order_by: [desc: :inserted_at, desc_nulls_first: :invalidated_at]
      )

    {:noreply, assign(socket, :merchs, merchs)}
  end

  def handle_info(%{action: :save_merch} = payload, socket) do
    %{merch_id: merch_id} = payload
    %{merchs: merchs} = socket.assigns
    merch = Transcript.get_merchandise(merch_id)
    {:noreply, assign(socket, :merchs, [merch | merchs])}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def handle_event("toggle-snapshot-modal", %{"snapshot" => snapshot_url}, socket) do
    assigns = %{
      snapshot_modal_url: snapshot_url
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("toggle-edit-merch", %{"merch-id" => merch_id}, socket) do
    %{merchs: merchs0} = socket.assigns

    merchs1 =
      Enum.map(merchs0, fn
        %{id: ^merch_id, editing: editing} = m -> Map.put(m, :editing, !editing)
        %{id: ^merch_id} = m -> Map.put(m, :editing, true)
        m -> m
      end)

    {:noreply, assign(socket, :merchs, merchs1)}
  end

  def handle_event("update-merch", %{"merch" => merch_params}, socket) do
    %{merchs: merchs0} = socket.assigns
    merch_id = merch_params["id"]

    {:ok, merch} =
      merch_id
      |> Transcript.get_merchandise()
      |> Transcript.save_merchandise(%{
        price: merch_params["price"],
        title: merch_params["title"]
      })

    merchs1 =
      Enum.map(merchs0, fn
        %{id: ^merch_id} -> merch
        m -> m
      end)

    {:noreply, assign(socket, :merchs, merchs1)}
  end

  def handle_event("update-merch", _, socket), do: {:noreply, socket}

  def handle_event("toggle-merch-valid", %{"merch-id" => merch_id}, socket) do
    %{merchs: merchs0} = socket.assigns

    {:ok, merch} = merch_id |> Transcript.get_merchandise() |> toggle_merch_validity

    merchs1 =
      Enum.map(merchs0, fn
        %{id: ^merch_id} -> merch
        m -> m
      end)

    {:noreply, assign(socket, :merchs, merchs1)}
  end

  defp toggle_merch_validity(merch) do
    invalidated_at =
      if !merch.invalidated_at do
        NaiveDateTime.utc_now()
      end

    merch
    |> Map.from_struct()
    |> Map.put(:invalidated_at, invalidated_at)
    |> Transcript.save_merchandise()
  end
end
