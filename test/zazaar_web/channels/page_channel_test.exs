defmodule ZaZaarWeb.PageChannelTest do
  use ZaZaarWeb.ChannelCase

  alias ZaZaarWeb.PageChannel

  setup do
    user = insert(:user)
    page = insert(:page, user: user)

    {:ok, page: page, user: user}
  end

  describe "join a channel" do
    test "only signed in user can join page channel", ctx do
      %{page: page, user: user} = ctx
      {:ok, user_token, _} = ZaZaar.Auth.Guardian.encode_and_sign(user)
      {:ok, page_token, _} = ZaZaar.Auth.Guardian.encode_and_sign(page)
      {:ok, socket} = connect(UserSocket, %{user_token: user_token})

      assert {:ok, _reply, _socket} =
               join(socket, "page:" <> page.fb_page_id, %{page_token: page_token})
    end
  end
end
