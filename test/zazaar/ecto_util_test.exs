defmodule ZaZaar.EctoUtilTest do
  use ZaZaar.DataCase

  alias ZaZaar.EctoUtil
  alias ZaZaar.Transcript.Merchandise

  describe "get_many_query/3" do
    test "generate query from attrs" do
      query =
        Merchandise
        |> EctoUtil.get_many_query(%{buyer_fb_id: "foobar"})

      assert %{from: %{source: {"merchandises", Merchandise}}} = query

      %{wheres: wheres} = query

      assert Enum.count(wheres) == 1
    end

    test "returns count when get_count option is true" do
      assert %{select: %{expr: {:count, _, _}}} =
               EctoUtil.get_many_query(Merchandise, %{}, get_count: true)
    end
  end
end
