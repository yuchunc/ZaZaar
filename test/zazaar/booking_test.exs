defmodule ZaZaar.BookingTest do
  use ZaZaar.DataCase

  alias ZaZaar.Booking
  alias Booking.Order

  describe "create_video_orders/1" do
    test "when an empty list is given, returns empty list" do
      assert Booking.create_video_orders(insert(:video), []) == {:ok, []}
    end

    test "given a list of merchandises, create a list of orders" do
      video = insert(:video)
      merchs = insert_list(3, :merchandise, video: video)

      {:ok, orders} = Booking.create_video_orders(video, merchs)

      assert Enum.count(orders) == 3

      assert Enum.map(orders, & &1.id) |> Enum.sort() ==
               Repo.all(Order) |> Enum.map(& &1.id) |> Enum.sort()

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
      video = insert(:video)
      buyer_fb_id = random_obj_id()

      merchs =
        insert_list(3, :merchandise, video: video, buyer_fb_id: buyer_fb_id, buyer_name: "Joe")

      {:ok, [order]} = Booking.create_video_orders(video, merchs)

      order_1 = Repo.preload(order, :buyer)

      assert order_1.id == Repo.one(Order) |> Map.get(:id)
      assert order_1.buyer.fb_id == buyer_fb_id

      assert Enum.map(order_1.items, & &1.merchandise_id) |> Enum.sort() ==
               Enum.map(merchs, & &1.id) |> Enum.sort()
    end
  end
end
