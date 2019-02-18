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

      assert Enum.map(orders, & &1.id) |> Enum.sort() ==
               Repo.all(Order) |> Enum.map(& &1.id) |> Enum.sort()
    end
  end
end
