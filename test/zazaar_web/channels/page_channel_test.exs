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

      assert {:ok, socket} = connect(UserSocket, %{userToken: user_token})

      assert {:ok, _reply, _socket} =
               join(socket, "page:" <> page.fb_page_id, %{"pageToken" => page_token})
    end
  end

  describe "merchandise:save event" do
    test "generates a new merchandise", ctx do
      %{page: %{access_token: access_token} = page, user: user} = ctx
      socket = joined_page_socket(user, page)
      %{fb_video_id: fb_video_id} = video = insert(:video)
      merch_map = params_for(:merchandise, video_id: video.id)

      expect(ApiMock, :get_object_edge, fn :thumbnails, ^fb_video_id, ^access_token, _ ->
        resp = %{"data" => Enum.map(1..10, fn _ -> RespMock.thumbnail() end)}
        {:ok, resp}
      end)

      push(socket, "merchandise:save", merch_map)

      assert_broadcast("merchandise:updated", _payload)
      assert merch = Repo.get_by(Merchandise, video_id: video.id)
      refute is_nil(merch.snapshot_url)
    end

    test "update an existing merchandise", ctx do
      %{page: %{access_token: access_token} = page, user: user} = ctx
      socket = joined_page_socket(user, page)
      new_title = "99 Bottles of Bear"
      %{fb_video_id: fb_video_id} = video = insert(:video)

      merch =
        insert(:merchandise, video: video)
        |> Map.from_struct()
        |> Map.put(:title, new_title)

      expect(ApiMock, :get_object_edge, fn :thumbnails, ^fb_video_id, ^access_token, _ ->
        resp = %{"data" => Enum.map(1..10, fn _ -> RespMock.thumbnail() end)}
        {:ok, resp}
      end)

      push(socket, "merchandise:save", merch)

      assert_broadcast("merchandise:updated", payload)
      assert payload.title == new_title
      assert payload.snapshot_url == merch.snapshot_url
    end
  end

  describe "comment:save event" do
    test "save a new comment, publish to Facebook, and broadcast", ctx do
      %{page: page, user: user} = ctx
      socket = joined_page_socket(user, page)
      %{id: video_id} = video = insert(:video)

      message = "oheiohei"

      expect(ApiMock, :publish, fn :comments, _, _, _ ->
        resp = RespMock.comment(message: message, parent_id: video.fb_video_id)
        {:ok, resp}
      end)

      push(socket, "comment:save", %{object_id: video.fb_video_id, message: message})

      assert_broadcast "video:new_comments", %{video_id: ^video_id, comments: comments}

      comment_ids =
        Repo.get(Video, video.id)
        |> Map.get(:comments)
        |> Enum.map(& &1.object_id)

      result_ids =
        comments
        |> Enum.map(& &1.object_id)

      assert result_ids -- comment_ids == []
    end
  end

  describe "internal:new_comments event" do
    test "broadcast new comments to channel", ctx do
      %{page: page, user: user} = ctx
      socket = joined_page_socket(user, page)
      video_id = Ecto.UUID.generate()

      push(socket, "internal:new_comments", %{video_id: video_id, comments: []})

      assert_broadcast "video:new_comments", %{video_id: video_id, comments: []}
    end
  end
end
