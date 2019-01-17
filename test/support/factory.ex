defmodule ZaZaar.Factory do
  use ExMachina.Ecto, repo: ZaZaar.Repo

  alias ZaZaar.{Account, Transcript}

  # ====== Account =========
  @valid_tasks ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]

  def user_factory do
    %Account.User{
      name: Faker.Name.name(),
      email: Faker.Internet.email(),
      fb_id: "integer with somelength"
    }
  end

  def page_factory do
    %Account.Page{
      access_token: StreamData.string(:alphanumeric, length: 64) |> Enum.at(0),
      fb_page_id: random_obj_id(),
      name: StreamData.string(:alphanumeric, length: 10) |> Enum.at(0),
      tasks:
        StreamData.member_of(@valid_tasks) |> StreamData.list_of(max_length: 5) |> Enum.at(0),
      user: build(:user)
    }
  end

  # ====== Transcript =========
  def video_factory do
    page_id = random_obj_id()
    vid_id = random_obj_id()

    %Transcript.Video{
      creation_time: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      embed_html: "<iframe src=#{Faker.Internet.url()}></iframe>",
      image_url: "https://fbcdn.net/#{page_id}_#{vid_id}_n.jpg",
      fb_page_id: page_id,
      permalink_url: "/" <> page_id <> "/videos/" <> vid_id,
      fb_video_id: vid_id,
      fb_status: :vod
    }
  end

  def comment_factory do
    %Transcript.Comment{
      message: Faker.Lorem.sentence(),
      created_time: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      object_id: random_obj_id() <> "_" <> random_obj_id(),
      commenter_fb_id: random_obj_id(),
      commenter_fb_name: Faker.Name.name()
    }
  end

  def merchandise_factory do
    %Transcript.Merchandise{
      buyer_fb_id: random_obj_id(),
      buyer_name: Faker.Name.name(),
      price: Enum.random(0..20_000),
      snapshot_url: Faker.Internet.url(),
      title: Faker.Pizza.pizza(),
      video: build(:video)
    }
  end

  # ====== Helper =========
  def random_obj_id() do
    Enum.random(100_000_000_000_000..599_999_999_999_999) |> to_string
  end
end
