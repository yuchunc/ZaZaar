defmodule ZaZaar.Auth.UserErrorHandler do
  use ZaZaarWeb, :controller

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_flash(:danger, to_string(type))
    |> redirect(to: "/")
  end
end
