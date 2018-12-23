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

  @doc """
  This function fetches and stores Facebook feeds that is a video.
  Facebook only allows 100 feed per request, and max of 600 per year.

  https://developers.facebook.com/docs/graph-api/reference/v3.2/page/feed

  NOTE possibly use tags for identify 團購

  TODO any spec need to be identified
  """
  @spec fetch_feed(String.t()) :: any()
  def fetch_feed(access_token) do
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
