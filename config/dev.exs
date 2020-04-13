import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :zazaar, ZaZaarWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  live_view: [signing_salt: "udLfDC/dkeopmACsBHYgvMVtl7M+2Mh6"],
  watchers: [
    npm: [
      "run",
      "watch",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :zazaar, ZaZaarWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/zazaar_web/views/.*(ex)$},
      ~r{lib/zazaar_web/commanders/.*(ex)$},
      ~r{lib/zazaar_web/lives/.*(ex)},
      ~r{lib/zazaar_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :zazaar, ZaZaar.Repo,
  username: "postgres",
  password: "postgres",
  database: "zazaar_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :zazaar, ZaZaar.Auth.Guardian,
  secret_key: "p3dKt7RTFoUe8gPVoO9Qz9bGI7xowt0dyYuqDv/9KUdva8bS6fZc74oTtfy/Bnvk"

config :ex_ngrok,
  executable: "ngrok",
  protocol: "http",
  port: "4000",
  api_url: "http://localhost:4040/api/tunnels",
  sleep_between_attempts: 200

import_config "dev.secret.exs"
