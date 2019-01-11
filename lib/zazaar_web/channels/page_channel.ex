defmodule ZaZaarWeb.PageChannel do
  use ZaZaarWeb, :channel

  def join("page:" <> fb_page_id, %{page_token: page_token}, socket0) do
    {:ok, socket1} =
      Guardian.Phoenix.Socket.authenticate(socket0, Auth.Guardian, page_token, %{}, key: :page)

    page = current_page(socket1)

    # NOTE possibily verify if user has the proper permission to manage the page
    # check Page module for more detail on page permission
    if page.fb_page_id == fb_page_id do
      {:ok, socket1}
    else
      {:error, %{reason: "forbidden"}}
    end
  end
end
