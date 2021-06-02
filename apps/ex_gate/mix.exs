defmodule ExGate.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_gate,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      mod: {ExGate.Application, []},
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
      {:poison, "~> 4.0"},
      {:uuid, "~> 1.1"},
      {:ex_json_schema, "0.8.0-rc1"},
      {:tesla, "~> 1.4"},

      # Testing
      {:gun, "~> 1.3", only: [:test]},
      {:mock, "~> 0.3", only: :test},

      # Coverage
      {:excoveralls, "~> 0.14", only: [:dev, :test]}
    ]
  end
end
