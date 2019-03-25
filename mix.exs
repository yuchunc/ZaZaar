defmodule ZaZaar.MixProject do
  use Mix.Project

  def project do
    [
      app: :zazaar,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ZaZaar.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(:dev), do: ["lib", "test/support/factory.ex"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix
      {:phoenix, github: "phoenixframework/phoenix", branch: "v1.4", override: true},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.13", github: "phoenixframework/phoenix_html", override: true},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      # Auth
      {:argon2_elixir, "~> 2.0"},
      {:comeonin, "~> 5.0"},
      {:guardian, "~> 1.1"},
      {:ueberauth, "~> 0.5"},
      {:ueberauth_facebook, "~> 0.7"},
      # Utils
      {:drab, "~> 0.10.0"},
      {:ecto_enum, "~> 1.0"},
      {:facebook, "~> 0.22"},
      {:timex, "~> 3.1"},
      # Dev and Test Utils
      {:ex_machina, "~> 2.2", only: [:test, :dev]},
      {:faker, "~> 0.11", only: [:test, :dev]},
      {:stream_data, "~> 0.1", only: [:test, :dev]},
      {:mox, "~> 0.4", only: :test},
      {:ex_ngrok, "~> 0.3", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.migrate": ["ecto.migrate", "ecto.dump"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
