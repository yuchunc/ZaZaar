defmodule ZaZaar.FbResponseMock do
  @live_videos_default_fields [
    "title",
    "status",
    "stream_url",
    "secure_stream_url",
    "embed_html",
    "id"
  ]

  # @comment_default_fields ["created_time", "from", "message"]

  def page(opts0 \\ []) do
    opts1 = Enum.into(opts0, %{})

    default_tasks =
      ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]
      |> Enum.take_random(Enum.random(1..5))

    %{
      "access_token" => opts1.page_access_token || Faker.String.base64(32),
      "category" => "E-commerce Website",
      "category_list" => [
        %{"id" => "1756049968005436", "name" => "E-commerce Website"}
      ],
      "id" => opts1.page_id || Faker.UUID.v4(),
      "name" => opts1.page_name || Faker.Superhero.name(),
      "tasks" => opts1[:tasks] || default_tasks
    }
  end

  def video(fields \\ @live_videos_default_fields, list_opts \\ []) do
    random_status =
      ["LIVE", "PROCESSING", "VOD"]
      |> Enum.random()

    opts = Enum.into(list_opts, %{})
    page_id = opts[:page_id] || random_obj_id()
    video_id = opts[:video_id] || random_obj_id()

    image_url =
      Keyword.get(list_opts, :image_url, "https://fbcdn.net/#{page_id}_#{video_id}_n.jpg")

    Enum.reduce(fields, [{"id", random_obj_id()}], fn f, acc ->
      gen =
        case f do
          "embed_html" ->
            opts[:embed_html] || "<iframe src=\"fb_src\"></iframe>"

          "permalink_url" ->
            opts[:permalink_url] || ~s(/#{page_id}/videos/#{video_id}/)

          "video{picture}" ->
            %{"id" => video_id, "picture" => image_url}

          "video" ->
            %{"id" => video_id}

          "creation_time" ->
            opts[:creation_time] || current_time()

          "live_views" ->
            Enum.random(0..100)

          "status" ->
            opts[:status] || random_status

          f when f in ["title", "description"] ->
            Map.get(opts, String.to_atom(f)) || nil

          f ->
            Map.get(opts, String.to_atom(f)) || Faker.String.base64(20)
        end

      key = f |> String.split("{") |> List.first()
      [{key, gen} | acc]
    end)
    |> Enum.into(%{})
  end

  def comment(opts \\ []) do
    parent_id = Keyword.get(opts, :parent_id, random_obj_id())
    comment_id = Keyword.get(opts, :comment_id, random_obj_id())

    opts1 = Enum.into(opts, %{})

    %{
      "created_time" => opts1[:created_time] || current_time(),
      "from" => %{
        "name" => opts1[:name] || Faker.Name.name(),
        "id" => random_obj_id()
      },
      "message" => opts1[:message] || Faker.Lorem.sentence(),
      "id" => "#{parent_id}_#{comment_id}"
    }
  end

  def image_media(opts \\ []) do
    obj_id = Keyword.get(opts, :object_id, random_obj_id() <> "_" <> random_obj_id())
    src = Keyword.get(opts, :src, "https://fbcdn.net/#{obj_id}_n.jpg")

    %{
      "height" => 284,
      "is_silhouette" => false,
      "url" => src,
      "width" => 160
    }
  end

  def thumbnail(opts \\ %{}) do
    %{
      "id" => random_obj_id(),
      "height" => opts[:height] || 1280,
      "scale" => 1,
      "uri" =>
        "https://scontent.xx.fbcdn.net/v/t15.5256-10/#{random_obj_id()}_#{random_obj_id()}_n.jpg",
      "width" => opts[:width] || 720,
      "is_preferred" => opts[:preferred] || false
    }
  end

  def paging do
    %{
      "cursors" => %{
        "after" => "aftercursor",
        "before" => "beforecursor"
      }
    }
  end

  def summary(count \\ 100) do
    %{
      "order" => "ranked",
      "total_count" => count,
      "can_comment" => true
    }
  end

  def random_obj_id() do
    Enum.random(100_000_000_000_000..599_999_999_999_999) |> to_string
  end

  defp current_time do
    NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()
  end
end
