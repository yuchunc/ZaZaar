defmodule ZaZaar.BookingTest do
  use ZaZaar.DataCase

  describe "create_orders/1" do
    test "when an empty list is given, returns empty list" do
      assert Booking.create_orders([]) == []
    end

    test "given a list of merchandises, create a list of orders" do
      merchs = insert_list(3, :merchandise)

      {:ok, orders} = Booking.create_orders(merchs)
      assert Enum.count(orders) == 3
    end
  end
end
