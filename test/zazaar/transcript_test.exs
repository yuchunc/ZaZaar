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

    test "get video counts by attributes" do
      attr = [title: "bangbang", fb_page_id: "102301301103103201203"]
      insert_list(3, :video, attr)
      insert(:video)

      assert Transcript.get_videos(attr, get_count: true) == [3]
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
    test "update or insert video accordingly, and sorted by creation_time" do
      fb_page_id = "foofoobarbar"

      curr_vid_map =
        insert(:video, fb_page_id: fb_page_id)
        |> Map.from_struct()
        |> Map.delete(:__meta__)
        |> Map.delete(:comments)

      new_vid_map =
        build(:video,
          fb_page_id: fb_page_id,
          creation_time:
            NaiveDateTime.utc_now()
            |> NaiveDateTime.truncate(:second)
            |> NaiveDateTime.add(1, :second)
        )
        |> Map.from_struct()
        |> Map.delete(:__meta__)
        |> Map.delete(:comments)

      %{id: curr_vid_map_id} = curr_vid_map

      vid_maps = [Map.put(curr_vid_map, :id, nil), new_vid_map]

      assert {:ok, videos} = Transcript.upsert_videos(fb_page_id, vid_maps)
      assert [_, ^curr_vid_map_id] = videos |> Enum.map(& &1.id)
    end
  end

  describe "update_video/2" do
    test "update a video" do
      vid = insert(:video)

      comments =
        build_list(5, :comment, video_id: vid.id)
        |> Enum.map(&Map.from_struct/1)

      assert {:ok, res} = Transcript.update_video(vid, new_comments: comments)
      refute Enum.empty?(res.comments)
      assert res.comments |> Enum.count() == 5
    end

    test "update video with new comments" do
      vid = insert(:video)

      comments =
        build_list(5, :comment)
        |> Enum.map(&Map.from_struct/1)

      assert {:ok, res0} = Transcript.update_video(vid, fetched_comments: comments)
      refute Enum.empty?(res0.comments)

      comments1 =
        build_list(5, :comment)
        |> Enum.map(&Map.from_struct/1)

      assert {:ok, res1} = Transcript.update_video(vid, fetched_comments: comments ++ comments1)
      assert res1.comments |> Enum.count() == 10
    end
  end

  describe "save_merchandise/2" do
    test "inserts merchandise if doesn't exist" do
      merch_map = params_with_assocs(:merchandise)

      assert {:ok, merch} = Transcript.save_merchandise(merch_map)
      assert Ecto.get_meta(merch, :state) == :loaded
      assert merch.video_id == merch_map.video_id
    end

    test "udpates merchandise if exist" do
      new_title = "Gaga oooo lala"

      merch_map =
        insert(:merchandise)
        |> Map.from_struct()
        |> Map.put(:title, new_title)
        |> Map.put(:invalidated_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))

      assert {:ok, merch} = Transcript.save_merchandise(merch_map)
      assert merch.id == merch_map.id
      assert merch.title == new_title
    end
  end

  describe "get_comments/2" do
    setup do
      video = insert(:video)
      comments = insert_list(3, :comment, video_id: video.id)
      {:ok, comments: comments, video: video}
    end

    test "get by video", ctx do
      %{video: video, comments: comments} = ctx

      assert Transcript.get_comments(video) |> Enum.map(& &1.id) |> Enum.sort() ==
               comments |> Enum.map(& &1.id) |> Enum.sort()
    end

    test "get by attribute", ctx do
      %{video: video, comments: comments} = ctx

      assert Transcript.get_comments(video_id: video.id) |> Enum.map(& &1.id) |> Enum.sort() ==
               comments |> Enum.map(& &1.id) |> Enum.sort()
    end
  end

  describe "get_comment/2" do
    setup do
      {:ok, comment: insert(:comment)}
    end

    test "get comment by id", %{comment: comment} do
      assert Transcript.get_comment(comment.id) |> Map.get(:id) == comment.id
    end

    test "get comment by object_id", %{comment: comment} do
      assert Transcript.get_comment(comment.object_id) |> Map.get(:id) == comment.id
    end
  end

  describe "get_merchandise/1" do
    test "gets a merchandise" do
      %{id: id} = insert(:merchandise)

      assert %Merchandise{id: ^id} = Transcript.get_merchandise(id)
    end
  end

  describe "get_merchandises/2" do
    test "gets a list of merchandise for the video" do
      video = insert(:video)
      insert_list(5, :merchandise, video: video)

      assert merchs = Transcript.get_merchandises(video)
      assert Enum.count(merchs) == 5
      assert Enum.map(merchs, & &1.video_id) == List.duplicate(video.id, 5)
    end
  end
end
