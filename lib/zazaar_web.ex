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
      import ZaZaarWeb.Gettext
      alias ZaZaarWeb.Router.Helpers, as: Routes

      ZaZaarWeb.aliases()

      def current_user(conn), do: Guardian.Plug.current_resource(conn, key: :user)
      def current_page(conn), do: Guardian.Plug.current_resource(conn, key: :page)
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/zazaar_web/templates",
        namespace: ZaZaarWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ZaZaarWeb.ErrorHelpers
      import ZaZaarWeb.Gettext
      alias ZaZaarWeb.Router.Helpers, as: Routes

      ZaZaarWeb.aliases()

      def current_user(conn), do: Guardian.Plug.current_resource(conn, key: :user)
      def current_page(conn), do: Guardian.Plug.current_resource(conn, key: :page)
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller

      ZaZaarWeb.aliases()
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ZaZaarWeb.Gettext

      ZaZaarWeb.aliases()

      def current_user(conn), do: Guardian.Plug.current_resource(conn, key: :user)
      def current_page(conn), do: Guardian.Plug.current_resource(conn, key: :page)
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
      alias Transcript.Video

      alias ZaZaar.Account
      alias Account.{User, Page}
    end
  end
end
