defmodule ZaZaar.FbResponseMock do
  def pages(count, opts0 \\ []) do
    opts1 = Enum.into(opts0, %{})

    %{
      "access_token" => opts1.page_access_token || Faker.String.base64(32),
      "category" => "E-commerce Website",
      "category_list" => [
        %{"id" => "1756049968005436", "name" => "E-commerce Website"}
      ],
      "id" => opts1.page_id || Faker.UUID.v4(),
      "name" => opts1.page_name || Faker.Superhero.name(),
      "tasks" => ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]
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
end
