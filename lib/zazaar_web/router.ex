defmodule ZaZaarWeb.Router do
  use ZaZaarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Auth.UserPipeline
    plug Auth.PagePipeline
  end

  pipeline :public do
    plug Guardian.Plug.LoadResource, key: :user, allow_blank: true
  end

  pipeline :user_authed do
    plug Guardian.Plug.EnsureAuthenticated, key: :user
    plug Guardian.Plug.LoadResource, key: :user
  end

  pipeline :page_authed do
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, allow_blank: false
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

    resources "/i", InvoiceController, only: [:show]
  end

  scope "/webhook", ZaZaarWeb.Webhook do
    pipe_through [:api]
    resources "/facebook", FacebookController, singleton: true, only: [:show, :create]
  end

  scope "/", ZaZaarWeb, as: :config do
    pipe_through [:browser, :user_authed]

    resources "/config/pages", Config.FbPageController, only: [:index, :show]

    delete("/logout", SessionController, :delete)
  end

  scope "/", ZaZaarWeb do
    pipe_through [:browser, :user_authed, :page_authed]

    get "/m", StreamController, :index

    scope "/s" do
      resources "/current", StreamingController, singleton: true, only: [:show]
      resources "/", StreamController, only: [:show, :update]
      resources "/batch_orders", BatchOrderController, singleton: true, only: [:create]
    end

    resources "/o", OrderController, only: [:index, :show]
  end
end
