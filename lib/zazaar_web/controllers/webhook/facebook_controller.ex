defmodule ZaZaarWeb.Webhook.FacebookController do
  use ZaZaarWeb, :controller

  @webhook_secret Application.get_env(:facebook, :webhook_secret)

  def show(conn, params) do
    if params["hub.verify_token"] == @webhook_secret do
      %{"hub.challenge" => challenge} = params
      send_resp(conn, :ok, challenge)
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def create(conn, params) do
    send_resp(conn, :ok, "")
  end
end
