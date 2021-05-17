defmodule ExAuction.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      dialyzer: dialyzer(),
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
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "./priv/plts/dialyzer.plt"},
      ignore_warnings: ".dialyzer_ignore.exs"
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
      validate: ["credo --strict", "dialyzer"],
      "coveralls.html": ["coveralls.html --umbrella"]
    ]
  end
end
