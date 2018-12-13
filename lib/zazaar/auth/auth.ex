defmodule ZaZaar.Auth do
  alias Ueberauth.Auth, as: UAuth

  alias ZaZaar.Account

  def fb_auth(%UAuth{uid: uid} = uauth) do
    Account.get_user(fb_id: uid)
    |> post_fb_set_user(uauth)
  end

  def fb_auth(_), do: {:error, :ueberauth_struct_not_used}

  defp post_fb_set_user(nil, %UAuth{uid: uid, info: info, credentials: creds}) do
    %{
      fb_id: uid,
      name: info.name,
      email: info.email,
      image_url: info.image,
      fb_access_token: creds.token
    }
    |> Account.set_user()
  end

  defp post_fb_set_user(user, %UAuth{credentials: creds}) do
    Account.set_user(user, %{fb_access_token: creds.token})
  end
end
