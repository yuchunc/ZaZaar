defmodule ZaZaar.Booking do
  use ZaZaar, :context

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
  def create_video_orders(_video, []), do: []

  def create_video_orders(video, merchs) do
    users_with_items =
      Enum.group_by(merchs, &%{fb_id: &1.buyer_fb_id, fb_name: &1.buyer_name}, fn merch ->
        %Item{
          title: merch.title,
          price: merch.price
        }
      end)

    buyers =
      Repo.insert_all(Buyer, Map.keys(users_with_items),
        on_conflict: {:replace, [:fb_name]},
        conflict_target: [:fb_id, :page_id]
      )
      |> IO.inspect(label: "items")
  end
end
