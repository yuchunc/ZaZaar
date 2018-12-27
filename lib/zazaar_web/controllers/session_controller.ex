defmodule ZaZaarWeb.SessionController do
  use ZaZaarWeb, :controller

  alias Auth.Guardian.Plug, as: GPlug

  plug Ueberauth

  def create(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Auth.fb_auth(auth) do
      {:ok, user} ->
        conn
        |> GPlug.sign_in(user, %{}, key: :user)
        |> put_flash(:success, dgettext("success", "Login Successful"))
        |> redirect(to: "/config/pages")

      err ->
        err
    end
  end

  def delete(conn, _params) do
    conn
    |> GPlug.sign_out(key: :user)
    |> put_flash(:info, dgettext("success", "Logout Successful"))
    |> redirect(to: "/")
  end
end
