defmodule ZaZaar.Booking do
  use ZaZaar, :context

  import ZaZaar.EctoUtil
  import ZaZaar.TimeUtil

  alias ZaZaar.Booking
  alias Booking.{Order, Buyer, Item}

  alias ZaZaar.Transcript
  alias Transcript.Video
  alias Transcript.Merchandise, as: Merch

  @doc """
  Creates a list of orders from merchs,
  one order per video perperson
  """
  @spec create_video_orders(Video.t(), [Merch.t()], String.t()) :: [Order.t()]
  def create_video_orders(_video, [], _page_id), do: {:ok, []}

  def create_video_orders(video, merchs, page_id) do
    local_dt = video.creation_time |> convert_local_dt("Asia/Taipei")

    merchs = Enum.reject(merchs, &(!!&1.invalidated_at))

    users_with_items =
      Enum.group_by(
        merchs,
        &%{fb_id: &1.buyer_fb_id, fb_name: &1.buyer_name, page_id: page_id},
        fn merch ->
          %{
            merchandise_id: merch.id,
            title: merch.title,
            price: merch.price,
            snapshot_url: merch.snapshot_url,
            status: "active"
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

    Enum.reduce(users_with_items, order_count(page_id) + 1, fn {buyer_map, items}, count ->
      buyer = Enum.find(buyers, {:error, :buyer_not_found}, &(&1.fb_id == buyer_map.fb_id))
      str_count = count |> Integer.to_string() |> String.pad_leading(7, "0")

      {:ok, _} =
        save_order(%{
          page_id: page_id,
          buyer_id: buyer.id,
          video_id: video.id,
          title: str_count <> " " <> Timex.format!(local_dt, "%F %T", :strftime),
          total_amount: Enum.reduce(items, 0, &(&1.price + &2)),
          # inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          # updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          number: str_count,
          items: items
        })

      count + 1
    end)

    {:ok, get_orders(video_id: video.id)}
  end

  def get_orders(attrs, opts \\ []) do
    {assoc_attrs, order_attrs} = Keyword.split(attrs, [:buyer_name, :date_range])

    Order
    |> get_many_query(order_attrs, opts)
    |> additional_filters(assoc_attrs)
    |> Repo.all()
  end

  @spec save_order(attrs :: map) :: {:ok, Order.t()} | {:error, any}
  def save_order(attrs) do
    upsert_fields = [:void_at, :number, :title, :total_amount]

    struct(Order, Map.delete(attrs, :items))
    |> Order.changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: {:replace, upsert_fields}, conflict_target: :id)
  end

  @spec save_order(order :: Order.t(), attrs :: Map) :: {:ok, Order.t()} | {:error, any}
  def save_order(%Order{} = order, attrs) do
    order
    |> Map.from_struct()
    |> Map.merge(%{
      void_at: attrs[:void_at],
      number: attrs[:number],
      title: attrs[:title],
      total_amount: attrs[:total_amount],
      items: attrs[:items]
    })
    |> save_order
  end

  defp get_buyers(attrs) do
    Buyer
    |> get_many_query(attrs)
    |> Repo.all()
  end

  defp additional_filters(query, []), do: query

  defp additional_filters(query, [{_, value} | t]) when value == nil or value == "",
    do: additional_filters(query, t)

  defp additional_filters(query, [{:buyer_name, buyer_name} | t]) do
    query
    |> join(:inner, [order], buyer in assoc(order, :buyer))
    |> where([..., buyer], like(buyer.fb_name, ^"%#{buyer_name}%"))
    |> additional_filters(t)
  end

  defp additional_filters(query, [{:date_range, date_range} | t]) do
    query
    |> where(^filter_by_date_range(date_range, Date.utc_today()))
    |> additional_filters(t)
  end

  defp filter_by_date_range("today", now) do
    dynamic([o], o.inserted_at > date_add(^now, -1, "day"))
  end

  defp filter_by_date_range("yesterday", now) do
    dynamic(
      [o],
      o.inserted_at > date_add(^now, -2, "day") and o.inserted_at < date_add(^now, -1, "day")
    )
  end

  defp filter_by_date_range("this-week", now) do
    dynamic([o], o.inserted_at > date_add(^now, -1, "week"))
  end

  defp filter_by_date_range("last-week", now) do
    dynamic(
      [o],
      o.inserted_at > date_add(^now, -2, "week") and o.inserted_at < date_add(^now, -1, "week")
    )
  end

  defp filter_by_date_range("this-month", now) do
    dynamic([o], o.inserted_at > date_add(^now, -1, "month"))
  end

  defp filter_by_date_range("last-month", now) do
    dynamic(
      [o],
      o.inserted_at > date_add(^now, -2, "month") and
        o.inserted_at < date_add(^now, -1, "month")
    )
  end

  defp filter_by_date_range("this-year", now) do
    dynamic([o], o.inserted_at > date_add(^now, -1, "year"))
  end

  defp filter_by_date_range("last-year", now) do
    dynamic(
      [o],
      o.inserted_at > date_add(^now, -2, "year") and o.inserted_at < date_add(^now, -1, "year")
    )
  end

  defp filter_by_date_range(_, _), do: []

  defp order_count(page_id) do
    Order
    |> where(page_id: ^page_id)
    |> select(count())
    |> Repo.all()
    |> List.first()
  end
end
