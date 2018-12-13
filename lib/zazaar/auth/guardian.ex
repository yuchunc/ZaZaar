defmodule ZaZaar.Auth.Guardian do
  use Guardian, otp_app: :zazaar

  alias ZaZaar.Account
  alias Account.User

  def subject_for_token(%User{id: user_id}, _claims) do
    {:ok, user_id}
  end

  def resource_from_claims(%{"sub" => user_id}) do
    case Account.get_user(user_id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :resource_not_found}
    end
  end
end
