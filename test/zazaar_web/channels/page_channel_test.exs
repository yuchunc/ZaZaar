defmodule ZaZaarWeb.PageChannelTest do
  use ZaZaarWeb.ChannelCase

  import Mox

  alias ZaZaarWeb.PageChannel
  alias ZaZaar.FbApiMock, as: ApiMock

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    user = insert(:user)
    page = insert(:page, user: user)

    {:ok, page: page, user: user}
  end

  describe "join a channel" do
    test "only signed in user can join page channel", ctx do
      %{page: page, user: user} = ctx

      expect(ApiMock, :publish, fn :subscribed_apps, _obj_id, _, _access_token ->
        {:ok, %{"success" => true}}
      end)

      {:ok, user_token, _} = ZaZaar.Auth.Guardian.encode_and_sign(user)
      {:ok, page_token, _} = ZaZaar.Auth.Guardian.encode_and_sign(page)

      assert {:ok, socket} = connect(UserSocket, %{user_token: user_token})

      assert {:ok, _reply, _socket} =
               join(socket, "page:" <> page.fb_page_id, %{page_token: page_token})
    end
  end
end
