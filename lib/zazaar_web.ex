defmodule ZaZaarWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

  use ZaZaarWeb, :controller
  use ZaZaarWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ZaZaarWeb

      import Plug.Conn
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      import ZaZaarWeb.Gettext
      import ZaZaarWeb, only: :functions

      alias ZaZaarWeb.Router.Helpers, as: Routes

      ZaZaarWeb.aliases()
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/zazaar_web/templates",
        namespace: ZaZaarWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, action_name: 1, controller_module: 1]

      import Phoenix.LiveView.Helpers, only: [live_render: 3]

      use Phoenix.HTML

      import ZaZaarWeb.ErrorHelpers
      import ZaZaarWeb.Gettext
      import ZaZaarWeb, only: :functions

      alias ZaZaarWeb.Router.Helpers, as: Routes

      ZaZaarWeb.aliases()

      def custom_js(_), do: ""

      defoverridable custom_js: 1
    end
  end

  def live do
    quote do
      use Phoenix.LiveView

      import Phoenix.View, only: [render: 3]
      import ZaZaarWeb.Gettext

      alias Phoenix.LiveView.Socket
      alias ZaZaarWeb.Router.Helpers, as: Routes

      ZaZaarWeb.aliases()
    end
  end

  def commander do
    quote do
      import Phoenix.Socket
      import ZaZaarWeb.Gettext

      ZaZaarWeb.aliases()

      def current_user(socket), do: Guardian.Phoenix.Socket.current_resource(socket, :user)
      def current_page(socket), do: Guardian.Phoenix.Socket.current_resource(socket, :page)
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router

      ZaZaarWeb.aliases()
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ZaZaarWeb.Gettext

      ZaZaarWeb.aliases()

      def current_user(socket), do: Guardian.Phoenix.Socket.current_resource(socket, :user)
      def current_page(socket), do: Guardian.Phoenix.Socket.current_resource(socket, :page)
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  @doc """
  Add aliases for modules
  USE WITH CAUTION
  """
  defmacro aliases do
    quote do
      alias ZaZaarWeb.FallbackController

      alias ZaZaar.Auth

      alias ZaZaar.Fb

      alias ZaZaar.Transcript
      alias Transcript.{Video, Merchandise}

      alias ZaZaar.Account
      alias Account.{User, Page}

      alias ZaZaar.Booking
    end
  end

  def current_user(conn), do: Guardian.Plug.current_resource(conn, key: :user)
  def current_user(conn, :token), do: Guardian.Plug.current_token(conn, key: :user)
  def current_page(conn), do: Guardian.Plug.current_resource(conn, key: :page)
  def current_page(conn, :token), do: Guardian.Plug.current_token(conn, key: :page)
end
