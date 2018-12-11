defmodule ZaZaarWeb.Router do
  use ZaZaarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug(
      Guardian.Plug.Pipeline,
      module: ZaZaar.Auth.Guardian
    )

    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.LoadResource, allow_blank: true)
  end

  pipeline :auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZaZaarWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/privacy", PageController, :privacy
    get "/service", PageController, :service

    scope "/auth" do
      get("/:provider", SessionController, :request)
      get("/:provider/callback", SessionController, :create)
    end

    # TODO pipe this in to auth
    scope "/" do
      get "/m", StreamController, :index

      scope "/s" do
        resources "/", StreamController, only: [:show]
        resources "/current", StreamController, singleton: true, only: [:show]
      end

      resources "/o", OrderController, only: [:index, :show]
    end

    # NOTE user invoice path
    resources "/i", InvoiceController, only: [:show]
  end
end
