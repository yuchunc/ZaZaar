defmodule ZaZaarWeb.Config.FbPageController do
  use ZaZaarWeb, :controller

  alias Auth.Guardian.Plug, as: GPlug

  plug :put_view, ZaZaarWeb.ConfigView

  @doc """
  Display the pages selection for user.
  If user doesn't have any pages, fetch user pages from Facebook.
  """
  def index(conn, _) do
    with %User{} = user <- current_user(conn),
         pages0 <- Account.get_pages(user),
         {:ok, pages1} <- Fb.set_pages(user) do
      render(conn, "fb_pages.html", pages: Enum.sort_by(pages1, & &1.fb_page_id))
    end
  end

  def show(conn, %{"id" => page_id}) do
    case Account.get_page(page_id) do
      %Page{} = page ->
        conn
        |> GPlug.sign_in(page, %{}, key: :page)
        |> put_flash(
          :success,
          dgettext("success", "Welcome to your page: %{name}!", name: page.name)
        )
        |> redirect(to: "/m")

      _ ->
        conn
        |> put_flash(:warning, dgettext("errors", "Unable to find page."))
        |> redirect(to: "/config/pages")
    end
  end
end
