defmodule ZaZaar.Auth.PageErrorHandler do
  use ZaZaarWeb, :controller

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_flash(:warning, dgettext("errors", "Please Choose a Facebook Page."))
    |> redirect(to: "/config/pages")
  end
end
