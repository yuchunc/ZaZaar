defmodule ZaZaar.AccountTest do
  use ZaZaar.DataCase

  doctest ZaZaar.Account

  @valid_tasks ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]

  describe "get_user/1" do
    test "gets user from user id" do
      user = insert(:user)

      result = Account.get_user(user.id)

      assert user.id == result.id
    end

    test "get user from fb_id" do
      user = insert(:user, fb_id: "foobar")

      assert Account.get_user(fb_id: user.fb_id) |> Map.get(:fb_id) == user.fb_id
    end
  end

  describe "set_user/2" do
    test "if map is passed in as single arugment, insert a user" do
      params = params_for(:user)
      assert {:ok, %User{} = user} = Account.set_user(params)
      assert user.name == params.name
    end

    test "if no user is given, insert a user" do
      params = params_for(:user)
      assert {:ok, %User{} = user} = Account.set_user(nil, params)
      assert user.name == params.name
    end

    test "if user is given, update the user" do
      user = insert(:user, name: "foo")
      params = %{name: "bar"}
      assert {:ok, %User{} = user1} = Account.set_user(user, params)
      assert user.name != params.name
    end
  end

  describe "upsert_pages/1" do
    setup do
      pages_stream =
        StreamData.fixed_map(%{
          access_token: StreamData.string(:alphanumeric, length: 64),
          fb_page_id: StreamData.string(48..57, length: 12),
          name: StreamData.string(:alphanumeric, length: 10),
          tasks: StreamData.member_of(@valid_tasks) |> StreamData.list_of(max_length: 5)
        })

      [pages_stream: pages_stream, user: insert(:user)]
    end

    test "insert a page if user does has a current page", ctx do
      %{pages_stream: pages_stream, user: user} = ctx
      [page] = pages = Enum.take(pages_stream, 1)

      assert {:ok, [result]} = Account.upsert_pages(user, pages)
      assert result.access_token == page.access_token
      assert result.fb_page_id == page.fb_page_id
    end

    test "update a page if user already has a page", ctx do
      %{pages_stream: pages_stream, user: user} = ctx
      page = insert(:page, user: user)

      page_map =
        Enum.at(pages_stream, 0)
        |> Map.put(:fb_page_id, page.fb_page_id)

      assert {:ok, [result]} = Account.upsert_pages(user, [page_map])
      refute result.name == page.name
    end

    test "bulk insert and update pages", ctx do
      %{pages_stream: pages_stream, user: user} = ctx
      current_pages = insert_list(3, :page, user: user)

      page_maps =
        Enum.take(pages_stream, 3)
        |> Enum.with_index()
        |> Enum.map(fn {p, i} ->
          c_page = Enum.at(current_pages, i)
          Map.put(p, :fb_page_id, c_page.fb_page_id)
        end)
        |> Enum.concat(Enum.take(pages_stream, 3))
        |> Enum.shuffle()

      assert {:ok, pages} = Account.upsert_pages(user, page_maps)
      assert Enum.count(pages) == 6
    end

    test "accepts strategy :flush, and deletes existing data", ctx do
      %{pages_stream: pages_stream, user: user} = ctx
      current_pages = insert_list(4, :page, user: user)

      page_maps =
        Enum.take(pages_stream, 3)
        |> Enum.with_index()
        |> Enum.map(fn {p, i} ->
          c_page = Enum.at(current_pages, i)
          Map.put(p, :fb_page_id, c_page.fb_page_id)
        end)
        |> Enum.concat(Enum.take(pages_stream, 3))
        |> Enum.shuffle()

      assert {:ok, pages} = Account.upsert_pages(user, page_maps, strategy: :flush)
      assert Repo.all(Page) |> Enum.count() == 6
    end
  end

  describe "get_page/1" do
    test "gets a single page by string id" do
      page = insert(:page)

      assert Account.get_page(page.id) |> Map.get(:id) == page.id
    end

    test "gets page by attrs" do
      page = insert(:page)

      assert Account.get_page(fb_page_id: page.fb_page_id) |> Map.get(:id) == page.id
    end

    test "if doesn't exist returns nil" do
      assert Account.get_page(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_pages/1" do
    test "get pages by attribute" do
      attr = [name: "foobar"]
      insert_list(3, :page, attr)
      insert(:page)

      assert Account.get_pages(attr) |> Enum.count() == 3
    end

    test "get pages by attributes" do
      attr = [name: "bangbang", fb_page_id: "102301301103103201203"]
      insert_list(3, :page, attr)
      insert(:page)

      assert Account.get_pages(attr) |> Enum.count() == 3
    end
  end
end
