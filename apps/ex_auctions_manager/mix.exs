defmodule ExAuctionsManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_auctions_manager,
      version: "0.1.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :ssl],
      mod: {ExAuctionsManager.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.6", override: true},
      {:plug, "~> 1.11"},
      {:plug_cowboy, "~> 2.5"},
      {:corsica, "~> 1.1"},
      {:guardian, "~> 2.1"},
      {:tesla, "~> 1.4"},
      {:timex, "~> 3.7"},
      {:ex_gate, in_umbrella: true},
      {:ex_auctions_db, in_umbrella: true},

      # Code quality
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},

      # Coverage
      {:excoveralls, "~> 0.14", only: [:dev, :test]}
    ]
  end

  def aliases do
    [
      validate: ["credo --strict", "dialyzer"]
    ]
  end
end
