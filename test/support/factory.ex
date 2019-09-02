defmodule ZaZaar.Factory do
  use ExMachina.Ecto, repo: ZaZaar.Repo

  alias ZaZaar.{Account, Transcript, Booking}

  # ====== Account =========
  @valid_tasks ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]

  def user_factory do
    %Account.User{
      name: Faker.Name.name(),
      email: Faker.Internet.email(),
      fb_id: random_obj_id(),
      fb_access_token: StreamData.string(:alphanumeric, length: 64) |> Enum.at(0)
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
    video = insert(:video)

    %Transcript.Comment{
      message: Faker.Lorem.sentence(),
      created_time: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      object_id: random_obj_id() <> "_" <> random_obj_id(),
      commenter_fb_id: random_obj_id(),
      commenter_fb_name: Faker.Name.name(),
      video_id: video.id
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

  # ====== Booking =========
  def order_factory do
    page = insert(:page)
    video = insert(:video)

    %Booking.Order{
      title: Faker.Lorem.sentence(),
      total_amount: Enum.random(0..20000),
      page_id: page.fb_page_id,
      video_id: video.id,
      buyer: insert(:buyer, page_id: page.fb_page_id)
    }
  end

  def buyer_factory do
    page = insert(:page)

    %Booking.Buyer{
      fb_id: random_obj_id(),
      fb_name: Faker.Name.name(),
      page_id: page.fb_page_id
    }
  end

  # ====== Helper =========
  def random_obj_id() do
    Enum.random(100_000_000_000_000..599_999_999_999_999) |> to_string
  end
end
