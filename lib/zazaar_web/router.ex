defmodule ZaZaarWeb.Router do
  use ZaZaarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Auth.Pipeline
  end

  pipeline :public do
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  pipeline :auth do
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZaZaarWeb do
    pipe_through [:browser, :public]

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/privacy", PageController, :privacy
    get "/service", PageController, :service

    scope "/auth" do
      get("/:provider", SessionController, :request)
      get("/:provider/callback", SessionController, :create)
    end

    # NOTE user invoice path
    resources "/i", InvoiceController, only: [:show]
  end

  scope "/", ZaZaarWeb do
    pipe_through [:browser, :auth]

    get "/m", StreamController, :index

    scope "/s" do
      resources "/current", StreamingController, singleton: true, only: [:show]
      resources "/", StreamController, only: [:show]
    end

    scope "/config", Config do
      resources "/pages", PageController, singleton: true, only: [:show, :update]
    end

    delete("/logout", SessionController, :delete)

    resources "/o", OrderController, only: [:index, :show]
  end
end
