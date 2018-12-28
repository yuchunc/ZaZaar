defmodule ZaZaar.Fb do
  use ZaZaar, :context

  import ZaZaar.EctoUtil

  alias ZaZaar.Fb
  alias Fb.Video

  alias ZaZaar.Account
  alias Account.{User, Page}

  @api Application.get_env(:zazaar, :fb_api)

  @video_default_fields [
    "embed_html",
    "permalink_url",
    "creation_time",
    "video",
    "description",
    "title"
  ]

  @comment_default_fields ["created_time", "from", "message", "parent{id}"]

  @doc """
  fetches and stores Facebook Pages
  uses user access token
  """
  @spec set_pages(User.t()) :: {:ok, [Page.t()]} | {:error, String.t()}
  def set_pages(user) do
    with {:ok, %{"accounts" => accounts}} <- @api.me("accounts", user.fb_access_token),
         pages1 <- Enum.map(accounts["data"], &format_page_map/1) do
      Account.upsert_pages(user, pages1, strategy: :flush)
    else
      {:error, %{error: msg}} ->
        {:error, msg}
    end
  end

  @doc """
  fetches and stores Facebook live videos
  Uses pages access token.

  Please refer to
  https://developers.facebook.com/docs/graph-api/reference/live-video/
  for more details on how to use the endpoint

  Options:
  - `:fields` fields to fetch from Facebook
  - `:limit` limit per request

  NOTE possibly use tags for identify 團購
  """
  @spec fetch_videos(Page.t(), keyword) :: {:ok, [Video.t()]} | {:error, String.t()}
  def fetch_videos(%Page{} = page, opts \\ []) do
    %Page{access_token: access_token, fb_page_id: fb_page_id} = page

    fields =
      Keyword.get(opts, :fields, @video_default_fields)
      |> Enum.join(",")

    limit = Keyword.get(opts, :limit, 25)

    with {:ok, result} <-
           @api.get_object_edge("live_videos", fb_page_id, access_token,
             fields: fields,
             limit: limit
           ),
         %{"data" => videos0} <- result,
         videos1 <- Enum.map(videos0, &format_video_map/1),
         {:ok, video2} <- append_images(access_token, videos1) do
      upsert_videos(page.fb_page_id, video2)
    end
  end

  @doc """
  Fetches and stores Facebook comments into Video embedded list
  filter: :toplevel, :stream(default)
  summary: true, false(default)

  NOTE this attempts to fetch all comments at one go
  can be optimize by streaming the data
  """
  @spec fetch_comments(Video.t(), String.t(), keyword) :: {:ok, Video.t()} | {:error, any()}
  def fetch_comments(%Video{} = video, access_token, opts \\ []) do
    fields =
      Keyword.get(opts, :fields, @comment_default_fields)
      |> Enum.join(",")

    filter = Keyword.get(opts, :filter, :stream)
    summary = Keyword.get(opts, :summary, false)
    limit = Keyword.get(opts, :limit, 9_999_999)

    with req_opts <- [fields: fields, filter: filter, summary: summary, limit: limit],
         {:ok, result} <-
           @api.get_object_edge("comments", video.fb_video_id, access_token, req_opts),
         comments <- Map.get(result, "data", []) |> cast_comments,
         video_map <- Map.from_struct(video) |> Map.put(:comments, comments),
         {:ok, [video1]} <- upsert_videos(video.fb_page_id, [video_map]) do
      {:ok, video1}
    end
  end

  defp upsert_videos(fb_page_id, video_maps) do
    fb_video_ids = Enum.map(video_maps, & &1.fb_video_id)
    current_videos = get_videos(fb_page_id: fb_page_id, fb_video_id: fb_video_ids)

    videos =
      Enum.map(video_maps, fn vm ->
        video_struct = %Video{
          embed_html: vm.embed_html,
          image_url: vm.image_url,
          fb_page_id: fb_page_id,
          permalink_url: vm.permalink_url,
          fb_video_id: vm.fb_video_id
        }

        current_videos
        |> Enum.find(video_struct, &(&1.fb_video_id == vm.fb_video_id))
        |> Video.changeset(vm)
        |> Repo.insert_or_update!()
      end)

    {:ok, videos}
  end

  @doc """
  Gets a list of videos from DB
  """
  @spec get_videos(attrs :: Video.t() | keyword) :: [Video.t()]
  def get_videos(%Page{} = page), do: get_videos(fb_page_id: page.fb_page_id)

  def get_videos(attrs) do
    Video
    |> get_many_query(attrs)
    |> Repo.all()
  end

  defp append_images(access_token, videos) do
    with post_obj_ids <- Enum.map(videos, & &1.post_id),
         {:ok, datum} <- @api.get_edge_objects("", post_obj_ids, access_token, fields: "picture"),
         image_list <- Enum.map(datum, fn {k, %{"picture" => img_url}} -> {k, img_url} end) do
      videos1 =
        Enum.map(videos, fn v ->
          {_k, img_url} = Enum.find(image_list, fn {k, _} -> v.post_id == k end)
          Map.put(v, :image_url, img_url)
        end)

      {:ok, videos1}
    end
  end

  defp format_page_map(raw) do
    %{
      access_token: raw["access_token"],
      fb_page_id: raw["id"],
      name: raw["name"],
      tasks: raw["tasks"]
    }
  end

  defp cast_comments(comments0) when is_list(comments0) do
    Enum.map(comments0, fn c ->
      created_time =
        c["created_time"] |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.truncate(:second)

      %{
        message: c["message"],
        created_time: created_time,
        object_id: c["id"],
        parent_object_id: c["parent"]["id"],
        commenter_fb_id: c["from"]["id"],
        commenter_fb_name: c["from"]["name"]
      }
    end)
  end

  defp format_video_map(video) do
    [_, page_id, _, video_id, _] = String.split(video["permalink_url"], "/")

    status =
      case video["status"] do
        "LIVE" -> :live
        _ -> :vod
      end

    %{
      creation_time: video["creation_time"],
      description: video["description"],
      embed_html: video["embed_html"],
      permalink_url: video["permalink_url"],
      post_id: page_id <> "_" <> video_id,
      title: video["title"],
      fb_video_id: video_id,
      fb_status: status
    }
  end
end
