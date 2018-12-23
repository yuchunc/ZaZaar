defmodule ZaZaar.FbResponseMock do
  @live_videos_default_fields [
    "title",
    "status",
    "stream_url",
    "secure_stream_url",
    "embed_html",
    "id"
  ]

  def pages(opts0 \\ []) do
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

  def videos(fields \\ @live_videos_default_fields, list_opts \\ []) do
    random_status =
      ["LIVE", "PROCESSING", "VOD"]
      |> Enum.random()

    page_id = list_opts[:page_id] || random_obj_id
    video_id = list_opts[:video_id] || random_obj_id
    opts = Enum.into(list_opts, %{})

    Enum.reduce(fields, [{"id", random_obj_id}], fn f, acc ->
      gen =
        case f do
          "embed_html" ->
            opts[:embed_html] || "<iframe src=\"fb_src\"></iframe>"

          "permalink_url" ->
            opts[:permalink_url] || ~s(/#{page_id}/videos/#{video_id}/)

          "video" ->
            %{"id" => video_id}

          "creation_time" ->
            opts[:creation_time] || NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

          "live_views" ->
            Enum.random(0..100)

          "status" ->
            opts[:status] || random_status

          f when f in ["title", "description"] ->
            Map.get(opts, String.to_atom(f)) || nil

          f ->
            Map.get(opts, String.to_atom(f)) || Faker.String.base64(20)
        end

      if gen do
        [{f, gen} | acc]
      else
        acc
      end
    end)
    |> Enum.into(%{})
  end

  def image_media(opts \\ []) do
    obj_id = Keyword.get(opts, :object_id, random_obj_id <> "_" <> random_obj_id)
    src = Keyword.get(opts, :src, "https://fbcdn.net/_n.jpg")

    {
      obj_id,
      %{
        "id" => obj_id,
        "picture" => src
      }
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

  def random_obj_id do
    Enum.random(100_000_000_000_000..599_999_999_999_999) |> to_string
  end
end
