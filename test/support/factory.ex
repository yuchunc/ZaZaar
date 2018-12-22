defmodule Factory do
  use ExMachina.Ecto, repo: ZaZaar.Repo

  alias ZaZaar.{Account}

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
      fb_page_id: StreamData.string(48..57, length: 12) |> Enum.at(0),
      name: StreamData.string(:alphanumeric, length: 10) |> Enum.at(0),
      tasks:
        StreamData.member_of(@valid_tasks) |> StreamData.list_of(max_length: 5) |> Enum.at(0),
      user: build(:user)
    }
  end
end
