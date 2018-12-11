defmodule ZaZaar.Auth.ErrorHandler do
  use ZaZaarWeb, :controller

  def auth_error(conn, {:unauthenticated, reason}, _opts) do
    conn
    |> put_flash(:danger, reason)
    |> redirect(to: "/")
  end
end
