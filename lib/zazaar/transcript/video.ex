defmodule ZaZaar.Transcript.Video do
  use ZaZaar, :schema

  alias ZaZaar.Transcript

  @type t :: %__MODULE__{
          creation_time: NaiveDateTime.t(),
          description: nil | String.t(),
          embed_html: String.t(),
          image_url: String.t(),
          fb_page_id: String.t(),
          fb_status: FbLiveVideoStatus.__enum_map__(),
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
    field :permalink_url, :string
    field :fb_status, FbLiveVideoStatus
    field :fb_page_id, :string
    field :fb_video_id, :string
    field :post_obj_id, :string, virtual: true
    field :title, :string
    field :completed_at, :naive_datetime

    embeds_many :comments, Transcript.Comment

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [
      :creation_time,
      :description,
      :title,
      :fb_status,
      :completed_at
    ])
    |> cast_embed(:comments)
    |> validate_required([
      :embed_html,
      :permalink_url,
      :creation_time,
      :image_url,
      :fb_video_id,
      :fb_page_id,
      :fb_status
    ])
    |> validate_inclusion(:fb_status, FbLiveVideoStatus.__valid_values__())
  end
end
