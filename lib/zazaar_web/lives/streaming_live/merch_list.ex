defmodule ZaZaarWeb.StreamingLive.MerchList do
  use ZaZaarWeb, :live

  @default_state %{
    merchs: []
  }

  def render(assigns), do: render(ZaZaarWeb.StreamingView, "merch_list.html", assigns)

  def mount(session, socket) do
    %{video_id: video_id} = session

    send(self(), {:mounted, video_id})

    {:ok, assign(socket, @default_state)}
  end

  def handle_info({:mounted, video_id}, socket) do
    merchs =
      Transcript.get_merchandises(video_id,
        order_by: [desc_nulls_first: :invalidated_at, desc: :inserted_at]
      )

    {:noreply, assign(socket, :merchs, merchs)}
  end

  def handle_event("edit-merch", params, socket) do
    %{"merch-id" => merch_id} = params
    %{assigns: %{merchs: merchs0}} = socket

    merchs1 =
      Enum.map(merchs0, fn
        %{id: ^merch_id} = merch -> Map.put(merch, :editing, true)
        merch -> merch
      end)

    {:noreply, assign(socket, :merchs, merchs1)}
  end

  def handle_event("invalidate-merch", params, socket) do
    %{"merch-id" => merch_id} = params
    %{assigns: %{merchs: merchs0}} = socket

    merchs1 = Enum.map(merchs0, &toggle_merch(&1, merch_id, :invalidate))

    {:noreply, assign(socket, :merchs, merchs1)}
  end

  def handle_event("reactiveate-merch", params, socket) do
    %{"merch-id" => merch_id} = params
    %{assigns: %{merchs: merchs0}} = socket

    merchs1 = Enum.map(merchs0, &toggle_merch(&1, merch_id, :activate))

    {:noreply, assign(socket, :merchs, merchs1)}
  end

  def hand_event("cancel-merch-edit", params, socket) do
    {:noreply, socket}
  end

  defp toggle_merch(%{id: merch_id} = merch0, merch_id, action) do
    invalidated_at =
      case action do
        :invalidate -> NaiveDateTime.utc_now()
        _ -> nil
      end

    {:ok, merch1} =
      merch0
      |> Map.from_struct()
      |> Map.put(:invalidated_at, invalidated_at)
      |> IO.inspect(label: "map")
      |> Transcript.save_merchandise()

    merch1
  end

  defp toggle_merch(merch, _, _), do: merch
end
