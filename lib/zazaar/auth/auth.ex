defmodule ZaZaar.Auth do
  alias Ueberauth.Auth, as: UAuth

  alias ZaZaar.Account

  def fb_auth(%UAuth{uid: uid, info: info}) do
    case Account.get_user(fb_id: uid) do
      nil ->
        %{fb_id: uid, name: info.name, email: info.email, image_url: info.image}
        |> Account.set_user()

      user ->
        {:ok, user}
    end
  end

  def fb_auth(_), do: {:error, :ueberauth_struct_not_used}
end
