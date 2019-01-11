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

      alias ZaZaarWeb.UserSocket

      # The default endpoint for testing
      @endpoint ZaZaarWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ZaZaar.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ZaZaar.Repo, {:shared, self()})
    end

    :ok
  end

  def sign_socket(%ZaZaar.Account.User{} = user) do
    connect(UserSocket, %{})
    {:ok, jwt, _} = ZaZaar.Auth.Guardian.encode_and_sign(user)
    {:ok, socket} = connect(UserSocket, %{token: jwt})
    socket
  end
end
