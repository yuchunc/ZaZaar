defmodule ZaZaarWeb.Webhook.FacebookController do
  use ZaZaarWeb, :controller

  require Logger

  alias ZaZaarWeb.Endpoint

  @webhook_secret Application.get_env(:facebook, :webhook_secret)

  def show(conn, params) do
    if params["hub.verify_token"] == @webhook_secret do
      %{"hub.challenge" => challenge} = params
      send_resp(conn, :ok, challenge)
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def create(conn, %{"field" => "feed", "value" => event}) do
    Logger.info("fb webhook event: #{inspect(event)}")

    with [fb_page_id, fb_video_id] = String.split(event["post_id"], "_"),
         %Page{} = page <- Account.get_page(fb_page_id),
         %Video{} = video <- Transcript.get_video(fb_video_id),
         {:ok, video1} <- Fb.fetch_comments(video, page.access_token),
         new_comments <- video1.comments -- video.comments do
      payload = %{video_id: fb_video_id, comments: new_comments}
      Endpoint.broadcast!("page:#{fb_page_id}", "internal:new_comments", payload)
      send_resp(conn, :ok, "")
    else
      _err ->
        send_resp(conn, :ok, "")
    end
  end

  def create(conn, _) do
    send_resp(conn, :ok, "")
  end
end
