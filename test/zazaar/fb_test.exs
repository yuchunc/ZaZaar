defmodule ZaZaar.FbTest do
  use ZaZaar.DataCase

  import Mox

  alias ZaZaar.Fb
  alias ZaZaar.Account
  alias Account.Page

  alias ZaZaar.FbApiMock, as: ApiMock
  alias ZaZaar.FbResponseMock, as: RespMock

  setup :verify_on_exit!

  describe "set_pages/1" do
    test "get list of pages and stores pages in Account" do
      user = insert(:user)

      opts = [
        page_access_token: "lookatmeIamaccesstoken",
        page_name: "some page name",
        page_id: "1736200000004778"
      ]

      expect(ApiMock, :me, fn "accounts", _ ->
        resp = %{
          "accounts" => %{
            "data" => [
              RespMock.pages(1, opts)
            ]
          },
          "paging" => RespMock.paging()
        }

        {:ok, resp}
      end)

      assert {:ok, [page]} = Fb.set_pages(user)
      assert page.__struct__ == Page
      assert page.name == Keyword.get(opts, :page_name)
      assert page.access_token == Keyword.get(opts, :page_access_token)
      assert page.fb_page_id == Keyword.get(opts, :page_id)
      refute Enum.empty?(page.tasks)
    end
  end
end
