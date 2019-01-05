defmodule ZaZaar.Transcript do
  use ZaZaar, :context

  import ZaZaar.EctoUtil

  alias ZaZaar.Transcript
  alias Transcript.Video

  @doc """
  Gets a list of videos from DB
  """
  @spec get_videos(attrs :: Video.t() | keyword) :: [Video.t()]
  def get_videos(attrs), do: get_videos(attrs, [])

  @spec get_videos(attrs :: Video.t() | keyword, opts :: keyword) :: [Video.t()]
  def get_videos(%{fb_page_id: page_id}, opts), do: get_videos([fb_page_id: page_id], opts)

  def get_videos(attrs, opts) do
    order_by = Keyword.get(opts, :order_by, [])

    Video
    |> get_many_query(attrs)
    |> order_by(^order_by)
    |> Repo.all()
  end
end
