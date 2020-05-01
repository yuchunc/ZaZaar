import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zazaar, ZaZaarWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :zazaar, ZaZaar.Repo,
  database: "zazaar_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :zazaar, :fb_api, ZaZaar.FbApiMock

config :zazaar, ZaZaar.Auth.Guardian,
  secret_key: "p3dKt7RTFoUe8gPVoO9Qz9bGI7xowt0dyYuqDv/9KUdva8bS6fZc74oTtfy/Bnvk"

import_config "dev.secret.exs"
