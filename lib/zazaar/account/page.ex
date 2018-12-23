defmodule ZaZaar.Account.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias ZaZaar.Account

  @type t :: %__MODULE__{
          access_token: String.t(),
          fb_page_id: String.t(),
          tasks: [String.t()],
          user_id: String.t(),
          user: nil | Account.User.t()
        }

  @valid_tasks ["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pages" do
    field :access_token, :string
    field :fb_page_id, :string
    field :name, :string
    field :tasks, {:array, :string}

    belongs_to :user, Account.User

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name])
    |> validate_change(:tasks, &validate_tasks/2)
    |> validate_required([:fb_page_id, :access_token, :tasks, :name, :user_id])
    |> unique_constraint(:fb_page_id, name: :pages_user_id_fb_page_id_index)
    |> assoc_constraint(:user)
  end

  defp validate_tasks(:tasks, tasks) do
    invalid_tasks = Enum.uniq(tasks) -- @valid_tasks

    if Enum.empty?(invalid_tasks) do
      []
    else
      [task: "Invalid tasks: " <> Enum.join(invalid_tasks, ", ")]
    end
  end
end
