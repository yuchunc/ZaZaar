defmodule ZaZaar.Account.User do
  use ZaZaar, :schema

  @type t :: %__MODULE__{
          email: String.t(),
          fb_access_token: String.t(),
          fb_id: String.t(),
          image_url: String.t(),
          name: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :fb_access_token, :string
    field :fb_id, :string
    field :image_url, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :image_url, :fb_access_token])
    |> validate_required([:name, :fb_id])
  end
end
