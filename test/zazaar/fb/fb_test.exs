defmodule ZaZaar.FbTest do
  use ZaZaar.DataCase

  import Mox
  alias ZaZaar.FbApiMock, as: ApiMock
  alias ZaZaar.Fb
  alias ZaZaar.Account
  alias Account.Page

  setup :verify_on_exit!

  describe "set_pages/1" do
    test "get list of pages and stores pages in Account" do
      user = insert(:user)
      page_access_token = "lookatmeIamaccesstoken"
      page_name = "some page name"
      page_id = "1736200000004778"

      expect(ApiMock, :me, fn "accounts", _ ->
        resp = %{
          "accounts" => %{
            "data" => [
              %{
                "access_token" => page_access_token,
                "category" => "E-commerce Website",
                "category_list" => [
                  %{"id" => "1756049968005436", "name" => "E-commerce Website"}
                ],
                "id" => page_id,
                "name" => page_name,
                "tasks" => ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]
              }
            ]
          },
          "paging" => %{
            "cursors" => %{
              "after" => "aftercursor",
              "before" => "beforecursor"
            }
          }
        }

        {:ok, resp}
      end)

      assert {:ok, [page]} = Fb.set_pages(user)
      assert page.name == page_name
      assert page.access_token == page_access_token
      assert page.fb_page_id == page_id
      refute Enum.empty?(page.tasks)
    end
  end
end
