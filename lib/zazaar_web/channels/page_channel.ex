defmodule ZaZaarWeb.PageChannel do
  use ZaZaarWeb, :channel

  def join("page:" <> fb_page_id, %{"pageToken" => page_token}, socket0) do
    with {:ok, socket1} <-
           Guardian.Phoenix.Socket.authenticate(socket0, Auth.Guardian, page_token, %{},
             key: :page
           ),
         # NOTE possibily verify if user has the proper permission to manage the page
         # check Page module for more detail on page permission
         page <- current_page(socket1),
         true <- page.fb_page_id == fb_page_id do
      send(self(), {:after_auth, page})
      {:ok, socket1}
    else
      :error -> {:error, %{reason: "unauthorized"}}
      false -> {:error, %{reason: "forbidden"}}
    end
  end

  def handle_info({:after_auth, page}, socket) do
    Fb.start_subscribe(page)
    {:noreply, socket}
  end

  # NOTE find a way to unify both this events
  def handle_info({:new_comments, payload}, socket) do
    payload1 = Map.take(payload, [:video_id, :comments])
    broadcast!(socket, "video:new_comments", payload1)
    {:noreply, socket}
  end

  def handle_in("internal:new_comments", payload, socket) do
    %{"video_id" => video_id, "comments" => comments} = payload
    broadcast!(socket, "video:new_comments", %{video_id: video_id, comments: comments})
    {:noreply, socket}
  end

  def handle_in("merchandise:save", payload, socket) do
    with page <- current_page(socket),
         merch_map0 <- map_merchandise(payload),
         %Video{} = video <- Transcript.get_video(merch_map0.video_id),
         {:ok, %{"data" => thumbnails}} <-
           Fb.video_thumbnails(video.fb_video_id, page.access_token),
         merch_map1 <- apply_snapshot(merch_map0, thumbnails),
         {:ok, merch} <- Transcript.save_merchandise(merch_map1) do
      broadcast_from!(socket, "merchandise:updated", merch)
      {:reply, {:ok, merch}, socket}
    else
      _ ->
        {:reply, {:error, "can't create merchandise"}, socket}
    end
  end

  # def handle_in("comment:save", payload, socket) do
  #   %{"object_id" => fb_video_id, "message" => message} = payload
  #   page = current_page(socket)
  #   video = Transcript.get_video(fb_video_id)

  #   {:ok, comment} = Fb.publish_comment(fb_video_id, message, page.access_token)

  #   send(self(), {:new_comments, %{video_id: video.id, comments: [comment]}})
  #   {:noreply, socket}
  # end

  defp map_merchandise(merch) do
    %{
      id: merch["id"],
      video_id: merch["video_id"],
      buyer_fb_id: merch["buyer_fb_id"],
      buyer_name: merch["buyer_name"],
      price: merch["price"],
      title: merch["title"],
      invalidated_at: merch["invalidated_at"],
      live_timestamp: merch["live_broadcast_timestamp"]
    }
  end

  defp apply_snapshot(merch_map, []), do: merch_map

  defp apply_snapshot(merch_map, thumbnails) do
    %{"uri" => uri} = _ = List.last(thumbnails)
    Map.put(merch_map, :snapshot_url, uri)
  end
end
