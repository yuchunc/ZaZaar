defmodule ZaZaar.TranscriptTest do
  use ZaZaar.DataCase

  # alias ZaZaar.Transcript
  # alias Transcript.{Video, Comment}

  describe "get_videos/1" do
    test "get videos by an attribute" do
      attr = [title: "foobar"]
      insert_list(3, :video, attr)
      insert(:video)

      assert Transcript.get_videos(attr) |> Enum.count() == 3
    end

    test "get videos by attributes" do
      attr = [title: "bangbang", fb_page_id: "102301301103103201203"]
      insert_list(3, :video, attr)
      insert(:video)

      assert Transcript.get_videos(attr) |> Enum.count() == 3
    end
  end

  describe "get_video/1" do
    test "get video by id" do
      vid = insert(:video)

      assert result = %Video{} = Transcript.get_video(vid.id)
      assert result.id == vid.id
    end

    test "get video by fb_video_id" do
      vid = insert(:video)

      assert result = %Video{} = Transcript.get_video(vid.fb_video_id)
      assert result.id == vid.id
    end
  end

  describe "upsert_videos/2" do
    test "update or insert video accordingly" do
      fb_page_id = "foofoobarbar"

      curr_vid_map =
        insert(:video, fb_page_id: fb_page_id)
        |> Map.from_struct()
        |> Map.delete(:__meta__)

      new_vid_map =
        build(:video, fb_page_id: fb_page_id)
        |> Map.from_struct()
        |> Map.delete(:__meta__)

      vid_maps = [curr_vid_map, new_vid_map]

      assert {:ok, videos} = Transcript.upsert_videos(fb_page_id, vid_maps)
    end
  end
end
