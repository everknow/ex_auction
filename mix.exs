defmodule ExAuction.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
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
      ],
      # Docs
      name: "Auctions",
      docs: [
        formatters: ["html"]
      ],
      releases: releases()
    ]
  end

  defp deps do
    [
      # Code quality
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},

      # Docs
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.reset --quiet", "ecto.migrate --quiet", "test --trace"],
      validate: ["credo --strict", "dialyzer"],
      "coveralls.html": ["coveralls.html --umbrella"]
    ]
  end

  defp releases do
    [
      ex_auctions: [
        applications: [
          ex_auctions_db: :permanent,
          ex_auctions_manager: :permanent,
          ex_auctions_admin: :permanent,
          ex_gate: :permanent
        ],
        include_executables_for: [:unix],
        steps: [:assemble, :tar]
      ]
    ]
  end
end
