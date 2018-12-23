defmodule ZaZaar.Fb do
  use ZaZaar.Context

  alias ZaZaar.Fb
  alias Fb.Video

  alias ZaZaar.Account
  alias Account.{User, Page}

  @api Application.get_env(:zazaar, :fb_api)
  @default_fields [
    "embed_html",
    "permalink_url",
    "creation_time",
    "video",
    "description",
    "title"
  ]

  @spec set_pages(User.t()) :: {:ok, [Page.t()]} | {:error, String.t()}
  def set_pages(user) do
    with {:ok, %{"accounts" => accounts}} <- @api.me("accounts", user.fb_access_token),
         pages1 <- Enum.map(accounts["data"], &format_page_map/1),
         pages2 <- Account.upsert_pages(user, pages1) do
      pages2
    else
      {:error, %{error: msg}} ->
        {:error, msg}
    end
  end

  @doc """
  This function fetches and stores Facebook feeds that is a video.
  Facebook only allows 100 feed per request, and max of 600 per year.

  https://developers.facebook.com/docs/graph-api/reference/v3.2/page/feed

  NOTE possibly use tags for identify 團購
  """
  @spec fetch_videos(Page.t()) :: {:ok, [Video.t()]} | {:error, String.t()}
  def fetch_videos(%Page{} = page, opts \\ []) do
    fields = Keyword.get(opts, :fields, @default_fields)

    with {:ok, %{"data" => videos0}} <-
           @api.get_object_edge("live_videos", page.fb_page_id, page.access_token,
             fields: Enum.join(fields, ",")
           ),
         videos1 <- Enum.map(videos0, &format_video_map/1),
         {:ok, video2} <- append_images(page, videos1) do
      upsert_videos(page, video2)
    end
  end

  defp upsert_videos(%Page{} = page, video_maps) do
    fb_video_ids = Enum.map(video_maps, & &1.fb_video_id)
    current_videos = get_videos(page_id: page.fb_page_id, fb_video_id: fb_video_ids)

    videos =
      Enum.map(video_maps, fn vm ->
        current_videos
        |> Enum.find(%Video{page_id: page.id}, &(&1.video_id == vm.video_id))
        |> Video.changeset(vm)
        |> Repo.insert_or_update!()
      end)

    {:ok, videos}
  end

  defp get_videos(attrs), do: get_videos(Video, attrs)

  defp get_videos(query, []), do: Repo.all(query)

  defp get_videos(query, [{k, values} | t]) when is_list(values) do
    query
    |> where([v], field(v, ^k) in ^values)
    |> get_videos(t)
  end

  defp get_videos(query, [{k, value} | t]) do
    query
    |> where([v], field(v, ^k) == ^value)
    |> get_videos(t)
  end

  defp append_images(page, videos) do
    with post_obj_ids <- Enum.map(videos, & &1.post_id),
         {:ok, datum} <-
           @api.get_edge_objects("attachment", post_obj_ids, page.access_token, fields: "media"),
         image_list <-
           Enum.map(datum, fn {k, %{"data" => [data]}} -> {k, data["media"]["image"]["src"]} end) do
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

  defp format_video_map(video) do
    [_, page_id, _, video_id, _] = String.split(video["permalink_url"], "/")

    %{
      creation_time: video["creation_time"],
      description: video["description"],
      embed_html: video["embed_html"],
      permalink_url: video["permalink_url"],
      post_id: page_id <> "_" <> video_id,
      title: video["title"],
      fb_video_id: video_id
    }
  end
end
