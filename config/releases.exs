import Config

fb_id = System.get_env("FB_ID") || raise "FB_ID is missing"
fb_secret = System.get_env("FB_SECRET") || raise "FB_SECRET is missing"

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :zazaar, ZaZaar.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("DB_POOL") || "10")

config :facebook,
  app_id: fb_id,
  app_secret: fb_secret,
  app_access_token: nil,
  graph_url: "https://graph.facebook.com",
  graph_video_url: "https://graph-video.facebook.com",
  request_conn_timeout: nil,
  request_recv_timeout: nil

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: fb_id,
  client_secret: fb_secret

config :zazaar, ZaZaarWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  server: true

config :zazaar, ZaZaar.Auth.Guardian, secret_key: secret_key_base
