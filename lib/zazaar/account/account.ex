defmodule ZaZaar.Account do
  @moduledoc """
  Account Context Module
  """

  use ZaZaar, :context

  alias ZaZaar.Account
  alias Account.{User, Page}

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

  @doc """
  Insert or Update Facebook page permissions
  This is probably just going to be used internally
  """
  def upsert_pages(user, page_maps) do
    fb_page_ids = Enum.map(page_maps, & &1.fb_page_id)
    current_pages = get_pages(user_id: user.id, fb_page_id: fb_page_ids)

    pages =
      Enum.map(page_maps, fn pm ->
        page_struct = %Page{
          user_id: user.id,
          fb_page_id: pm.fb_page_id,
          tasks: pm.tasks,
          access_token: pm.access_token
        }

        current_pages
        |> Enum.find(page_struct, &(&1.fb_page_id == pm.fb_page_id))
        |> Page.changeset(pm)
        |> Repo.insert_or_update!()
      end)

    {:ok, pages}
  end

  defp get_pages(attrs), do: get_pages(Page, attrs)

  defp get_pages(query, []), do: Repo.all(query)

  defp get_pages(query, [{k, v} | t]) when is_list(v) do
    query
    |> where([p], field(p, ^k) in ^v)
    |> get_pages(t)
  end

  defp get_pages(query, [{k, v} | t]) do
    query
    |> where([p], field(p, ^k) == ^v)
    |> get_pages(t)
  end
end
