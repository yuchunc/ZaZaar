defmodule ZaZaarWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  use Phoenix.ChannelTest

  @endpoint ZaZaarWeb.Endpoint

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest
      import ZaZaar.Factory
      import ZaZaarWeb.ChannelCase

      require ZaZaarWeb

      alias ZaZaar.Repo
      alias ZaZaarWeb.UserSocket

      # The default endpoint for testing
      @endpoint ZaZaarWeb.Endpoint

      ZaZaarWeb.aliases()
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ZaZaar.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ZaZaar.Repo, {:shared, self()})
    end

    :ok
  end

  def joined_page_socket(%ZaZaar.Account.User{} = user, %ZaZaar.Account.Page{} = page) do
    {:ok, user_token, _} = ZaZaar.Auth.Guardian.encode_and_sign(user)
    {:ok, page_token, _} = ZaZaar.Auth.Guardian.encode_and_sign(page)

    Mox.expect(ZaZaar.FbApiMock, :publish, fn :subscribed_apps, _obj_id, _, _access_token ->
      {:ok, %{"success" => true}}
    end)

    {:ok, socket} = connect(ZaZaarWeb.UserSocket, %{user_token: user_token})
    subscribe_and_join!(socket, "page:" <> page.fb_page_id, %{page_token: page_token})
  end
end
