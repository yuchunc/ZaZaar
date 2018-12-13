defmodule ZaZaar.Account do
  @moduledoc """
  Account Context Module
  """

  use ZaZaar.Context

  alias ZaZaar.Account
  alias Account.User

  @doc """
  Finds a single user record in DB
  """
  def get_user(args) when is_list(args) do
    Repo.get_by(User, args)
  end

  def get_user(user_id) do
    Repo.get(User, user_id)
  end

  @doc """
  Sets the User in DB
  """
  def set_user(%{} = params), do: set_user(nil, params)

  def set_user(nil, params) do
    %User{fb_id: params.fb_id}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def set_user(%User{} = user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
