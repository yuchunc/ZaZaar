defmodule ZaZaar.FbTest do
  use ZaZaar.DataCase

  import Mox

  alias ZaZaar.Fb

  alias ZaZaar.Transcript
  alias Transcript.{Video, Comment}

  alias ZaZaar.Account
  alias Account.Page

  alias ZaZaar.FbApiMock, as: ApiMock
  alias ZaZaar.FbResponseMock, as: RespMock

  setup :verify_on_exit!

  describe "set_pages/1" do
    test "get list of pages and stores pages in Account" do
      user = insert(:user)

      opts = [
        page_access_token: "lookatmeIamaccesstoken",
        page_name: "some page name",
        page_id: "1736200000004778"
      ]

      expect(ApiMock, :me, fn "accounts", _ ->
        resp = %{
          "accounts" => %{
            "data" => [
              RespMock.page(opts)
            ]
          },
          "paging" => RespMock.paging()
        }

        {:ok, resp}
      end)

      assert {:ok, [page]} = Fb.set_pages(user)
      assert page.__struct__ == Page
      assert page.name == Keyword.get(opts, :page_name)
      assert page.access_token == Keyword.get(opts, :page_access_token)
      assert page.fb_page_id == Keyword.get(opts, :page_id)
      refute Enum.empty?(page.tasks)
    end
  end

  describe "fetch_videos/1" do
    test "get the latest feeds and stores them" do
      page = insert(:page)

      ApiMock
      |> expect(:get_object_edge, fn "live_videos", page_id, _, opts ->
        fields =
          "embed_html,permalink_url,creation_time,video{picture},description,status,title" =
          Keyword.get(opts, :fields)

        resp = %{
          "data" =>
            Enum.map(1..25, fn c ->
              fields
              |> String.split(",")
              |> RespMock.video(
                description: to_string(c),
                title: "Stream ##{c}",
                page_id: page_id
              )
            end),
          "paging" => RespMock.paging()
        }

        {:ok, resp}
      end)

      assert {:ok, result} = Fb.fetch_videos(page)
      assert Enum.count(result) == 25

      assert Enum.map(result, &{Map.get(&1, :__struct__), Ecto.get_meta(&1, :state)}) ==
               List.duplicate({Video, :loaded}, Enum.count(result))

      assert Enum.map(result, &Map.get(&1, :fb_page_id)) ==
               List.duplicate(page.fb_page_id, Enum.count(result))
    end
  end

  describe "fetch_comments/1" do
    test "fetch comments for video, and stores it in embedded schema" do
      video = insert(:video)
      count = 10
      access_token = "iamaccesstoken"

      ApiMock
      |> expect(:get_object_edge, fn "comments", obj_id, "iamaccesstoken", _ ->
        resp = %{
          "data" =>
            Enum.map(1..count, fn msg ->
              opts = [message: to_string(msg), parent_id: obj_id]
              RespMock.comment(opts)
            end)
        }

        {:ok, resp}
      end)
      |> expect(:stream, fn {:ok, %{"data" => comments}} ->
        obj_id = comments |> List.first() |> Map.get("parent_id")

        comments ++
          Enum.map(1..count, fn msg ->
            opts = [message: to_string(msg), parent_id: obj_id]
            RespMock.comment(opts)
          end)
      end)

      assert {:ok, result} = Fb.fetch_comments(video, access_token, strategy: :all)
      assert result.__struct__ == Video

      comments = result.comments
      assert comments |> Enum.map(& &1.__struct__) == List.duplicate(Comment, count * 2)

      assert comments |> Enum.map(& &1.message) ==
               Enum.map(1..count, &to_string/1) |> List.duplicate(2) |> List.flatten()
    end
  end

  describe "start_subscribe/1" do
    test "subscribe to page's Facebook webhook" do
      page = insert(:page)

      expect(ApiMock, :publish, fn :subscribed_apps, _obj_id, [], _access_token ->
        {:ok, %{"success" => true}}
      end)

      assert {:ok, _} = Fb.start_subscribe(page)
    end
  end

  describe "stop_subscribe/1" do
    test "stop subscribe to page's Facebook webhook" do
      page = insert(:page)

      expect(ApiMock, :remove, fn :subscribed_apps, _obj_id, _access_token ->
        {:ok, %{"success" => true}}
      end)

      assert {:ok, _} = Fb.stop_subscribe(page)
    end
  end

  describe "publish_comment/4" do
    test "push comment to facebook, with fields to get comments back" do
      video = insert(:video)
      access_token = "Imthealmightyaccesstoken"
      message = "foofoobarbar"

      ApiMock
      |> expect(:publish, fn :comments, _, [fields: _, message: msg], _ ->
        resp = RespMock.comment(message: msg, parent_id: video.fb_video_id)
        {:ok, resp}
      end)

      assert {:ok, %Comment{} = comment} =
               Fb.publish_comment(video.fb_video_id, message, access_token)
    end
  end
end
