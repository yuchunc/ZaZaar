defmodule ZaZaarWeb.Config.PageController do
  use ZaZaarWeb, :controller

  plug :put_view, ZaZaarWeb.ConfigView

  @doc """
  Display the pages selection for user.
  If user doesn't have any pages, fetch user pages from Facebook.
  """
  def index(conn, _) do
    with %User{} = user <- current_user(conn),
         pages0 <- Account.get_pages(user) do
      {:ok, pages1} =
        case pages0 do
          [] -> Fb.set_pages(user)
          pages -> {:ok, pages}
        end

      render(conn, "pages.html", pages: Enum.sort_by(pages1, & &1.fb_page_id))
    end
  end

  def show(conn, %{"id" => page_id}) do
    redirect(conn, to: "/m")
  end
end
