defmodule ZaZaarWeb.Router do
  use ZaZaarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

    # TODO introduce login path

    # TODO pipe this in to auth
    scope "/m" do
      get "/", StreamController, :index

      scope "/s" do
        resources "/", StreamController, only: [:show]
        resources "/current", StreamController, singleton: true, only: [:show]
      end

      resources "/o", OrderController, only: [:index, :show]
    end

    resources "/i", InvoiceController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZaZaarWeb do
  #   pipe_through :api
  # end
end
