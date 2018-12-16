defmodule ZaZaar.Fb do
  @api Application.get_env(:zazaar, :fb_api)

  def set_pages(access_token) do
    {:ok, %{"accounts" => %{"data" => pages}}} = @api.me("accounts", access_token)
  end
end
