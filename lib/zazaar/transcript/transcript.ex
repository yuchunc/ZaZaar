defmodule ZaZaar.Transcript do
  use ZaZaar, :context

  import Ecto.Changeset
  import ZaZaar.EctoUtil

  alias ZaZaar.Transcript
  alias Transcript.{Video, Comment, Merchandise}

  @doc """
  Get video by id or fb_video_id
  """
  @spec get_video(id_or_fb_video_id :: String.t(), opts :: keyword) :: nil | Video.t()

  def get_video(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    case id do
      <<_::288>> ->
        Repo.get(Video, id)

      _ ->
        Video
        |> where(fb_video_id: ^id)
        |> Repo.one()
    end
    |> Repo.preload(preload)
  end

  @doc """
  Gets a list of videos from DB
  """
  @spec get_videos(attrs :: %{fb_page_id: String.t()} | keyword) :: [Video.t()]
  def get_videos(attrs), do: get_videos(attrs, [])

  @spec get_videos(attrs :: %{fb_page_id: String.t()} | keyword, opts :: keyword) :: [Video.t()]
  def get_videos(%{fb_page_id: page_id}, opts), do: get_videos([fb_page_id: page_id], opts)

  def get_videos(attrs, opts) do
    Video
    |> get_many_query(attrs, opts)
    |> cast_videos_opts_to_query(opts)
    |> Repo.all()
  end

  @doc """
  Insert of Update a list of videos
  """
  @spec upsert_videos(fb_page_id :: String.t(), video_maps :: [map]) ::
          {:ok, [Video.t()]} | {:error, any}
  def upsert_videos(fb_page_id, video_maps) do
    video_maps
    |> Enum.map(&Map.put(&1, :fb_page_id, fb_page_id))
    |> upsert_videos
  end

  @spec upsert_videos(video_maps :: [%{fb_page_id: String.t()}]) ::
          {:ok, [Video.t()]} | {:error, any}
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

    {:ok, get_videos([fb_video_id: video_ids], order_by: [desc: :creation_time])}
  end

  @doc """
  Update a Video
  """
  @spec update_video(video :: Video.t() | String.t(), params :: keyword | map) ::
          {:ok, Video.t()} | {:error, any}
  def update_video(video_id, params) when is_binary(video_id),
    do: get_video(video_id) |> update_video(params)

  def update_video(video, params) when is_list(params),
    do: update_video(video, Enum.into(params, %{}))

  def update_video(video0, %{fetched_comments: comment_maps} = params) do
    video = Repo.preload(video0, :comments)

    new_comments =
      Enum.reject(comment_maps, fn cm ->
        Enum.find(video.comments, &(&1.object_id == cm.object_id))
      end)

    params1 =
      params
      |> Map.delete(:fetched_comments)
      |> Map.put(:new_comments, new_comments)

    update_video(video, params1)
  end

  def update_video(%Video{} = video0, params) do
    video = Repo.preload(video0, :comments)

    new_comments =
      params
      |> Map.get(:new_comments, [])
      |> Enum.map(&struct(Comment, &1))

    video
    |> Video.changeset(params)
    |> put_assoc(:comments, video.comments ++ new_comments)
    |> Repo.update()
  end

  @doc """
  gets a list of merchandises for video
  """
  @spec get_merchandises(attrs :: Video.t() | keyword | Ecto.UUID.t()) :: [Merchandise.t()]
  def get_merchandises(attrs), do: get_merchandises(attrs, [])

  @spec get_merchandises(attrs :: Video.t() | keyword | Ecto.UUID.t()) :: [Merchandise.t()]
  def get_merchandises(video_id, opts) when is_binary(video_id),
    do: get_merchandises(%{video_id: video_id}, opts)

  def get_merchandises(%Video{} = video, opts), do: get_merchandises(%{video_id: video.id}, opts)

  def get_merchandises(attrs, opts) do
    Merchandise
    |> get_many_query(attrs, opts)
    |> Repo.all()
  end

  @doc """
  gets a merchandise record
  """
  @spec get_merchandise(id :: Ecto.UUID.t()) :: %Merchandise{} | nil
  def get_merchandise(id) do
    Repo.get(Merchandise, id)
  end

  @doc """
  Update or Insert a Merchandise
  """
  @spec save_merchandise(attrs :: map) :: {:ok, Merchandise.t()} | {:error, any}
  def save_merchandise(attrs) do
    upsert_fields = [:title, :price, :invalidated_at]

    struct(Merchandise, attrs)
    |> Merchandise.changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: {:replace, upsert_fields}, conflict_target: :id)
  end

  @spec save_merchandise(merch :: Merchandise.t(), attrs :: Map) ::
          {:ok, Merchandise.t()} | {:error, any}
  def save_merchandise(%Merchandise{} = merch, attrs) do
    merch
    |> Map.from_struct()
    |> Map.merge(%{price: attrs[:price], title: attrs[:title]})
    |> save_merchandise()
  end

  @spec get_comments(attrs :: Video | keyword) :: Comments | []
  def get_comments(attrs), do: get_comments(attrs, [])

  @spec get_comments(attrs :: Video | keyword, opts :: keyword) :: Comments | []
  def get_comments(%Video{} = vid, opts), do: get_comments([video_id: vid.id], opts)

  def get_comments(attrs, opts) do
    Comment
    |> get_many_query(attrs, opts)
    |> cast_videos_opts_to_query(opts)
    |> Repo.all()
  end

  @spec get_comment(id :: String.t(), opts :: keyword) :: Comment | nil
  def get_comment(id_or_obj_id, _opts \\ []) do
    case id_or_obj_id do
      <<_::288>> ->
        Repo.get(Comment, id_or_obj_id)

      _ ->
        Comment
        |> where(object_id: ^id_or_obj_id)
        |> Repo.one()
    end
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

  defp cast_videos_opts_to_query(query, []), do: query

  defp cast_videos_opts_to_query(query, [{:on_date, date} | t]) do
    query
    |> where([v], fragment("?::date", v.creation_time) == ^date)
    |> cast_videos_opts_to_query(t)
  end

  defp cast_videos_opts_to_query(query, [_ | t]), do: cast_videos_opts_to_query(query, t)
end
