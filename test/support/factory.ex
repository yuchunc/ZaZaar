defmodule Factory do
  use ExMachina.Ecto, repo: ZaZaar.Repo

  alias ZaZaar.{Account}

  # ====== Account =========
  def user_factory do
    %Account.User{
      name: Faker.Name.name(),
      email: Faker.Internet.email(),
      fb_id: "integer with somelength"
    }
  end
end
