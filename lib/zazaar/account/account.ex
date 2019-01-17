defmodule ZaZaar.Account do
  @moduledoc """
  Account Context Module
  """

  use ZaZaar, :context

  import ZaZaar.EctoUtil

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
  Get a single fb page
  """
  @spec get_page(attr :: String.t()) :: Page.t() | nil
  def get_page(<<_::288>> = id), do: Repo.get(Page, id)

  def get_page(fb_page_id) do
    Page
    |> where(fb_page_id: ^fb_page_id)
    |> Repo.one()
  end

  @doc """
  Gets user fb pages from DB
  """
  @spec get_pages(attr :: User.t() | keyword) :: [Page.t()]
  def get_pages(attrs), do: get_pages(attrs, [])

  @spec get_pages(attr :: User.t() | keyword, opts :: keyword) :: [Page.t()]
  def get_pages(%User{id: user_id}, opts), do: get_pages([user_id: user_id], opts)

  def get_pages(attrs, opts) do
    order = Keyword.get(opts, :order_by, [])

    Page
    |> get_many_query(attrs)
    |> order_by(^order)
    |> Repo.all()
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
  @spec upsert_pages(%User{}, map, keyword) :: {:ok, [%Page{}]}
  def upsert_pages(user, page_maps, opts \\ []) do
    strategy = Keyword.get(opts, :strategy, :update)

    fb_page_ids = Enum.map(page_maps, & &1.fb_page_id)

    current_pages =
      case strategy do
        :flush ->
          get_many_query(Page, user_id: user.id) |> Repo.delete_all()
          []

        _ ->
          get_pages(user_id: user.id, fb_page_id: fb_page_ids)
      end

    pages =
      Enum.map(page_maps, fn pm ->
        page_struct = %Page{
          user_id: user.id,
          fb_page_id: pm.fb_page_id,
          tasks: pm.tasks,
          access_token: pm.access_token
        }

        do_upsert_pages(pm, page_struct, current_pages)
      end)

    {:ok, pages}
  end

  defp do_upsert_pages(page_map, page_struct, []) do
    page_struct
    |> Page.changeset(page_map)
    |> Repo.insert!()
  end

  defp do_upsert_pages(page_map, page_struct, current_pages) do
    current_pages
    |> Enum.find(page_struct, &(&1.fb_page_id == page_map.fb_page_id))
    |> Page.changeset(page_map)
    |> Repo.insert_or_update!()
  end
end
