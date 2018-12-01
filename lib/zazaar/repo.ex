defmodule ZaZaar.Repo do
  use Ecto.Repo,
    otp_app: :zazaar,
    adapter: Ecto.Adapters.Postgres
end
