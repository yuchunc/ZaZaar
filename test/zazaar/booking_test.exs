defmodule ZaZaar.BookingTest do
  use ZaZaar.DataCase

  alias ZaZaar.Booking
  alias Booking.Order

  describe "create_video_orders/1" do
    test "when an empty list is given, returns empty list" do
      assert Booking.create_video_orders(insert(:video), [], Ecto.UUID.generate()) == {:ok, []}
    end

    test "given a list of merchandises, create a list of orders" do
      page = insert(:page)
      video = insert(:video)
      merchs = insert_list(3, :merchandise, video: video)

      {:ok, orders} = Booking.create_video_orders(video, merchs, page.id)

      assert Enum.count(orders) == 3

      assert Enum.map(orders, & &1.id) |> Enum.sort() ==
               Repo.all(Order) |> Enum.map(& &1.id) |> Enum.sort()

      assert Enum.map(orders, & &1.page_id) == List.duplicate(page.id, 3)

      orders
      |> Repo.preload(:buyer)
      |> Enum.each(fn o ->
        assert Enum.find(merchs, fn m ->
                 m.buyer_fb_id == o.buyer.fb_id &&
                   m.id == o.items |> List.first() |> Map.get(:merchandise_id)
               end)
      end)
    end

    test "given a list of merchandise from the same user, create one order" do
      page = insert(:page)
      video = insert(:video)
      buyer_fb_id = random_obj_id()

      merchs =
        insert_list(3, :merchandise, video: video, buyer_fb_id: buyer_fb_id, buyer_name: "Joe")

      {:ok, [order]} = Booking.create_video_orders(video, merchs, page.id)

      order_1 = Repo.preload(order, :buyer)

      assert order_1.id == Repo.one(Order) |> Map.get(:id)
      assert order_1.buyer.fb_id == buyer_fb_id

      assert Enum.map(order_1.items, & &1.merchandise_id) |> Enum.sort() ==
               Enum.map(merchs, & &1.id) |> Enum.sort()
    end
  end

  describe "get_orders/1" do
    setup do
      buyer = insert(:buyer)
      page = insert(:page)
      orders = insert_list(3, :order, page_id: page.id, buyer: buyer)
      insert(:order)

      {:ok, page_id: page.id, orders: orders, buyer: buyer}
    end

    test "get orders with an attribute", ctx do
      assert Booking.get_orders(page_id: ctx.page_id) |> Enum.count() == 3
    end

    test "get orders with an attribute, with preloads", ctx do
      orders = Booking.get_orders([page_id: ctx.page_id], preload: :buyer)
      refute Enum.map(orders, & &1.buyer) == [nil, nil, nil]
    end

    test "filter by buyer's name", ctx do
      order = insert(:order, page_id: ctx.page_id)

      assert [result] = Booking.get_orders(page_id: ctx.page_id, buyer_name: order.buyer.fb_name)
      assert result.id == order.id
    end
  end

  describe "save_order/2" do
    setup do
      {:ok, order: insert(:order)}
    end

    test "can update an attribute on order", ctx do
      %{order: order} = ctx

      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      order_map = order |> Map.from_struct() |> Map.put(:void_at, now)

      assert {:ok, order} = Booking.save_order(order_map)
      assert !!order.void_at
    end
  end
end
