defmodule ZaZaar.Booking do
  use ZaZaar, :context

  import ZaZaar.EctoUtil
  import ZaZaar.TimeUtil

  alias ZaZaar.Booking
  alias Booking.{Order, Item, Buyer}

  alias ZaZaar.Transcript
  alias Transcript.Video
  alias Transcript.Merchandise, as: Merch

  @doc """
  Creates a list of orders from merchs,
  one order per video perperson
  """
  @spec create_video_orders(Video.t(), [Merch.t()]) :: [Order.t()]
  def create_video_orders(_video, []), do: {:ok, []}

  def create_video_orders(video, merchs) do
    local_dt = video.creation_time |> convert_local_dt("Asia/Taipei")

    users_with_items =
      Enum.group_by(
        merchs,
        &%{fb_id: &1.buyer_fb_id, fb_name: &1.buyer_name, page_id: video.fb_page_id},
        fn merch ->
          %Item{
            title: merch.title,
            price: merch.price
          }
        end
      )

    buyer_maps = Map.keys(users_with_items)

    Repo.insert_all(Buyer, buyer_maps,
      on_conflict: {:replace, [:fb_name]},
      conflict_target: [:fb_id, :page_id]
    )

    buyers =
      get_buyers(
        fb_id: Enum.map(buyer_maps, & &1.fb_id),
        page_id: Enum.map(buyer_maps, & &1.page_id)
      )

    {_, order_maps} =
      Enum.reduce(users_with_items, {1, []}, fn {buyer_map, items}, {count, acc} ->
        buyer = Enum.find(buyers, {:error, :buyer_not_found}, &(&1.fb_id == buyer_map.fb_id))

        {count + 1,
         [
           %{
             title: Timex.format!(local_dt, "%F %T", :strftime) <> " ##{count}",
             total_amount: Enum.reduce(items, 0, &(&1.price + &2)),
             page_id: video.fb_page_id,
             buyer_id: buyer.id,
             video_id: video.id,
             inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
             updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
             items: items
           }
           | acc
         ]}
      end)

    Enum.map(order_maps, fn om ->
      {:ok, order} =
        %Order{page_id: om.page_id, video_id: om.video_id, buyer_id: om.buyer_id}
        |> Order.changeset(om)
        |> Repo.insert()

      order
    end)

    {:ok, get_orders(video_id: video.id)}
  end

  defp get_buyers(attrs) do
    Buyer
    |> get_many_query(attrs)
    |> Repo.all()
  end

  defp get_orders(attrs) do
    Order
    |> get_many_query(attrs)
    |> Repo.all()
  end
end
