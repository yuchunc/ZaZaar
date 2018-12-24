defmodule ZaZaar.Fb.Video do
  use Ecto.Schema
  import Ecto.Changeset

  alias ZaZaar.Fb

  @type t :: %__MODULE__{
          creation_time: NaiveDateTime.t(),
          description: nil | String.t(),
          embed_html: String.t(),
          image_url: String.t(),
          fb_page_id: String.t(),
          permalink_url: String.t(),
          fb_video_id: String.t(),
          title: nil | String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "videos" do
    field :creation_time, :naive_datetime
    field :description, :string
    field :embed_html, :string
    field :image_url, :string
    field :fb_page_id, :string
    field :permalink_url, :string
    field :fb_video_id, :string
    field :post_obj_id, :string, virtual: true
    field :title, :string

    embeds_many :comments, Fb.Comment

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [
      :creation_time,
      :description,
      :title
    ])
    |> validate_required([
      :embed_html,
      :permalink_url,
      :creation_time,
      :image_url,
      :fb_video_id,
      :fb_page_id
    ])
  end
end
