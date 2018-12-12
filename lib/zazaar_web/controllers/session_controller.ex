defmodule ZaZaarWeb.SessionController do
  use ZaZaarWeb, :controller

  def delete(conn, _params) do
    conn
    |> GPlug.sign_out()
    |> put_flash(:info, dgettext("success", "Logout Successful"))
    |> redirect(to: "/")
  end

  def create(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, dgettext("error", "Login Failed"))
    |> redirect(to: "/")
  end

  def create(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    {:ok, user} = Account.fb_auth(auth.uid, auth.info)

    conn
    |> GPlug.sign_in(user)
    |> put_flash(:success, dgettext("success", "Login Successful"))
    |> redirect(to: "/")
  end
end
