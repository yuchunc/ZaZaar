defmodule ZaZaarWeb.Webhook.FacebookController do
  use ZaZaarWeb, :controller

  def show(conn, %{"id" => "facebook"} = params) do
    %{"hub.challenge" => challenge} = params

    send_resp(conn, :ok, challenge)
  end

  def create(conn, params) do
    send_resp(conn, :ok, "")
  end
end
