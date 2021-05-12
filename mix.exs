defmodule ExAuction.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_auction,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      mod: {ExAuction.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:cowboy, "~> 2.6", override: true},
      {:plug, "~> 1.11"},
      {:plug_cowboy, "~> 2.5"},
      {:corsica, "~> 1.1"},
      {:guardian, "~> 2.1"},
      {:tesla, "~> 1.4"},
      {:poison, "~> 4.0"},
      {:uuid, "~> 1.1"},

      # Code quality
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},

      # Testing
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:gun, "~> 1.3", only: [:test]},
      {:mock, "~> 0.3", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test --trace"],
      validate: ["credo --strict", "dialyzer"]
    ]
  end
end
