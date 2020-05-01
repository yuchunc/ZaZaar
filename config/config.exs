# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :zazaar,
  namespace: ZaZaar,
  ecto_repos: [ZaZaar.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :zazaar, ZaZaarWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fVKkwCPaWHCyGMLyhnwCvq81VLsiLM0b8fwSGPnJa70eeVewwhl7xN5n48NgNRCG",
  render_errors: [view: ZaZaarWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ZaZaar.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "ejxI5AHdkFAN0Fzt55Gm7lN82rVQCvTm"]

# Guardian Configs
config :zazaar, ZaZaar.Auth.Guardian,
  issuer: "zazaar",
  error_handler: ZaZaar.Auth.UserErrorHandler,
  verify_issuer: true

config :zazaar, :fb_api, ZaZaar.Fb.Api

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    facebook:
      {Ueberauth.Strategy.Facebook,
       [
         default_scope: "email,public_profile",
         profile_fields: "name,email,first_name,last_name",
         display: "popup"
       ]}
  ]

config :facebook,
  graph_url: "https://graph.facebook.com",
  graph_video_url: "https://graph-video.facebook.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
