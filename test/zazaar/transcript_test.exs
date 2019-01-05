defmodule ZaZaar.TranscriptTest do
  use ZaZaar.DataCase

  #alias ZaZaar.Transcript
  #alias Transcript.{Video, Comment}

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
end
