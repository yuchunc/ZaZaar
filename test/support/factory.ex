defmodule Factory do
  use ExMachina.Ecto, repo: ZaZaar.Repo

  alias ZaZaar.{Account, Fb}

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

  # ====== Account =========
  def video_factory do
    %Fb.Video{
      creation_time: NaiveDateTime.utc_now(),
      embed_html: "<iframe src=#{Faker.Internet.url()}></iframe>",
      image_url: Faker.Internet.url(),
      fb_page_id: random_obj_id(),
      permalink_url: Faker.Internet.url(),
      fb_video_id: random_obj_id()
    }
  end

  def random_obj_id() do
    Enum.random(100_000_000_000_000..599_999_999_999_999) |> to_string
  end
end
