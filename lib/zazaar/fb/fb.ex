defmodule ZaZaar.Fb do
  @api Application.get_env(:zazaar, :fb_api)

  alias ZaZaar.Account

  def set_pages(user) do
    with {:ok, %{"accounts" => accounts}} <- @api.me("accounts", user.fb_access_token),
         pages1 <- Enum.map(accounts["data"], &format_page_map/1),
         pages2 <- Account.upsert_pages(user, pages1) do
      pages2
    else
      {:error, %{error: msg}} ->
        {:error, msg}
    end
  end

  defp format_page_map(raw) do
    %{
      access_token: raw["access_token"],
      fb_page_id: raw["id"],
      name: raw["name"],
      tasks: raw["tasks"]
    }
  end
end
