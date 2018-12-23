defmodule ZaZaar.FbTest do
  use ZaZaar.DataCase

  import Mox

  alias ZaZaar.Fb
  alias Fb.Video

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
              RespMock.pages(opts)
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
      |> expect(:get_object_edge, fn "live_videos", page_id, _, _ ->
        resp = %{
          "data" =>
            Enum.map(1..11, fn c ->
              ["embed_html", "permalink_url", "creation_time", "video", "description", "title"]
              |> RespMock.videos(
                description: to_string(c),
                title: "Stream ##{c}",
                page_id: page_id
              )
            end) ++
              Enum.map(12..25, fn c ->
                ["embed_html", "permalink_url", "creation_time", "video", "description"]
                |> RespMock.videos(description: to_string(c), page_id: page_id)
              end),
          "paging" => RespMock.paging()
        }

        {:ok, resp}
      end)
      |> expect(:get_edge_objects, fn "attachment", obj_ids, _, _ ->
        resp =
          Enum.reduce(obj_ids, %{}, fn obj_id, acc ->
            {k, data} = RespMock.image_media(object_id: obj_id)
            Map.put_new(acc, k, data)
          end)

        {:ok, resp}
      end)

      assert {:ok, result} = Fb.fetch_videos(page)

      assert Enum.map(result, &{Map.get(&1, :__struct__), Ecto.get_meta(&1, :state)}) ==
               List.duplicate({Video, :loaded}, Enum.count(result))
    end
  end
end
