defmodule ZaZaar.Auth.Guardian do
  use Guardian, otp_app: :zazaar

  alias ZaZaar.Account
  alias Account.{User, Page}

  def subject_for_token(%User{id: user_id}, _claims) do
    {:ok, "User:" <> user_id}
  end

  def subject_for_token(%Page{id: page_id}, _) do
    {:ok, "Page:" <> page_id}
  end

  def resource_from_claims(%{"sub" => "User:" <> user_id}) do
    case Account.get_user(user_id) do
      %User{} = user -> {:ok, user}
      _ -> {:error, :resource_not_found}
    end
  end

  def resource_from_claims(%{"sub" => "Page:" <> page_id}) do
    case Account.get_page(page_id) do
      %Page{} = page -> {:ok, page}
      _ -> {:error, :resource_not_found}
    end
  end
end
