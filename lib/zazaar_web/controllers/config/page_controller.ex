defmodule ZaZaarWeb.Config.PageController do
  use ZaZaarWeb, :controller

  plug :put_view, ZaZaarWeb.ConfigView

  @doc """
  Display the pages selection for user.
  If user doesn't have any pages, fetch user pages from Facebook.
  """
  def show(conn, _) do
    with %User{} = user <- current_resource(conn),
         {:ok, pages} <- Fb.set_pages(user) do
      render(conn, "pages.html", pages: pages)
    end
  end

  def update(conn, _) do
    redirect(conn, to: "/m")
  end
end
