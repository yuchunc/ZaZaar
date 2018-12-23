defmodule ZaZaar.Auth.ErrorHandler do
  use ZaZaarWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_flash(:danger, to_string(type))
    |> redirect(to: "/")
  end
end
