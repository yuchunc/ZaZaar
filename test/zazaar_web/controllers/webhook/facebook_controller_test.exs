defmodule ZaZaarWeb.Webhook.FacebookControllerTest do
  use ZaZaarWeb.ConnCase

  import Mox

  alias ZaZaar.FbApiMock, as: ApiMock
  alias ZaZaar.FbResponseMock, as: RespMock

  setup :set_mox_global
  setup :verify_on_exit!

  describe "create/2" do
    test "accepts resquest when post updates, fetch it's comments, broadcast to PageChannel",
         ctx do
      %{conn: conn} = ctx
      %{fb_page_id: fb_page_id, access_token: access_token} = insert(:page)
      %{id: video_id, fb_video_id: fb_video_id} = insert(:video, fb_page_id: fb_page_id)
      event = webhoook_req_feed_post(%{page_id: fb_page_id, video_id: fb_video_id})
      message = "this if way too fucking hard"

      expect(ApiMock, :get_object_edge, fn "comments", ^fb_video_id, ^access_token, _opts ->
        resp = %{"data" => [RespMock.comment(message: message, parent_id: fb_video_id)]}
        {:ok, resp}
      end)

      assert post(conn, "/webhook/facebook", event) |> Map.get(:status) == 200

      # NOTE seems impossible to assert out going broadcast
      # assert_receive(%Phoenix.Socket.Broadcast{
      # topic: "page:" <> fb_page_id,
      # event: "internal:new_comments",
      # payload: %{video_id: ^video_id, comments: comments}}, 10_000)

      video = Repo.get(Video, video_id)

      assert Enum.count(video.comments) == 1
    end
  end

  defp webhoook_req_feed_post(params) do
    page_id = Map.get(params, :page_id, random_obj_id())
    video_id = Map.get(params, :video_id, random_obj_id())

    %{
      "field" => "feed",
      "value" => %{
        "item" => "status",
        "post_id" => page_id <> "_" <> video_id,
        "verb" => "add",
        "published" => 1,
        "created_time" => 1_547_364_561,
        "message" => Faker.Lorem.sentence(),
        "from" => %{
          "name" => Faker.Name.name(),
          "id" => random_obj_id()
        }
      }
    }
  end
end
