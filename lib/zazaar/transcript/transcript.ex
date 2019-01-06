defmodule ZaZaar.Transcript do
  use ZaZaar, :context

  import ZaZaar.EctoUtil

  alias ZaZaar.Transcript
  alias Transcript.Video

  @doc """
  Get video by id or fb_video_id
  """
  @spec get_video(id_or_fb_video_id :: String.t()) :: nil | %Video{}
  def get_video(<<_::288>> = id), do: Repo.get(Video, id)

  def get_video(fb_vid_id) do
    Video
    |> where(fb_video_id: ^fb_vid_id)
    |> Repo.one()
  end

  @doc """
  Gets a list of videos from DB
  """
  @spec get_videos(attrs :: %{fb_page_id: String.t()} | keyword) :: [Video.t()]
  def get_videos(attrs), do: get_videos(attrs, [])

  @spec get_videos(attrs :: %{fb_page_id: String.t()} | keyword, opts :: keyword) :: [Video.t()]
  def get_videos(%{fb_page_id: page_id}, opts), do: get_videos([fb_page_id: page_id], opts)

  def get_videos(attrs, opts) do
    order_by = Keyword.get(opts, :order_by, [])

    Video
    |> get_many_query(attrs)
    |> order_by(^order_by)
    |> Repo.all()
  end

  @doc """
  Insert of Update a list of videos
  """
  @spec upsert_videos(fb_page_id :: String.t(), video_maps :: [map]) ::
          {:ok, [%Video{}]} | {:error, any}
  def upsert_videos(fb_page_id, video_maps) do
    video_maps
    |> Enum.map(&Map.put(&1, :fb_page_id, fb_page_id))
    |> upsert_videos
  end

  @spec upsert_videos(video_maps :: [%{fb_page_id: String.t()}]) ::
          {:ok, [%Video{}]} | {:error, any}
  def upsert_videos(video_maps) do
    replace_fields = [:description, :image_url, :fb_status, :title]
    conflict_target = [:fb_video_id]

    video_maps1 =
      video_maps
      |> Enum.map(&prep_video_upsert_map/1)

    incoming_count = Enum.count(video_maps)

    {^incoming_count, _} =
      Video
      |> Repo.insert_all(video_maps1,
        on_conflict: {:replace, replace_fields},
        conflict_target: conflict_target
      )

    video_ids =
      video_maps
      |> Enum.map(& &1.fb_video_id)

    {:ok, get_videos(fb_video_id: video_ids)}
  end

  defp prep_video_upsert_map(input_map) do
    Map.merge(input_map, %{
      id: input_map[:id] || Ecto.UUID.generate(),
      inserted_at:
        input_map[:inserted_at] || NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at:
        input_map[:updated_at] || NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
  end

  # TODO Add update video here
end
