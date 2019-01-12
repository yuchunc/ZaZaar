defmodule ZaZaarWeb.PageChannelTest do
  use ZaZaarWeb.ChannelCase

  import Mox

  alias ZaZaar.FbApiMock, as: ApiMock
  alias ZaZaar.FbResponseMock, as: RespMock

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

  describe "merchandise:new event" do
    test "generates a new merchandise", ctx do
      %{page: page, user: user} = ctx
      socket = joined_page_socket(user, page)
      merch = params_with_assocs(:merchandise)

      ref = push(socket, "merchandise:save", merch)

      assert_reply(ref, :ok)
      assert Repo.get_by(Merchandise, video_id: merch.video_id)
      assert_broadcast("merchandise:updated", _payload)
    end

    test "update an existing merchandise", ctx do
      %{page: page, user: user} = ctx
      socket = joined_page_socket(user, page)
      new_title = "99 Bottles of Bear"

      merch =
        insert(:merchandise)
        |> Map.from_struct()
        |> Map.put(:title, new_title)

      ref = push(socket, "merchandise:save", merch)

      assert_reply(ref, :ok)
      assert Repo.get(Merchandise, merch.id)
      assert_broadcast("merchandise:updated", payload)
      assert payload.title == new_title
    end
  end

  describe "comment:save event" do
    test "save a new comment, publish to Facebook, and broadcast", ctx do
      %{page: page, user: user} = ctx
      socket = joined_page_socket(user, page)
      video = insert(:video)

      message = "oheiohei"

      expect(ApiMock, :publish, fn :comments, _, _, _ ->
        resp = RespMock.comment(message: message, parent_id: video.fb_video_id)
        {:ok, resp}
      end)

      push(socket, "comment:save", %{object_id: video.fb_video_id, message: message})

      assert_broadcast "video:new_comments", payload

      comment_ids =
        Repo.get(Video, video.id)
        |> Map.get(:comments)
        |> Enum.map(& &1.object_id)

      result_ids =
        payload.comments
        |> Enum.map(& &1.object_id)

      assert result_ids -- comment_ids == []
    end
  end
end
