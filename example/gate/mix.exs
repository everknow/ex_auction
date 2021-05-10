defmodule Gate.MixProject do
  use Mix.Project

  def project do
    [
      app: :gate,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gate.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [

      {:cowlib, "~> 2.9.1", override: true},
      {:cowboy, "~> 2.8", override: true},
      {:plug_cowboy, "~> 2.3"},
      {:guardian, "~> 2.1.1"},

      {:tesla, "~> 1.3"},
      {:hackney, "~> 1.16"},

      {:jason, "~> 1.2"},
      {:uuid, "~> 1.1"},

      {:corsica, "~> 1.1"},
      {:ex_json_schema, "~> 0.7.4"},

    ]
  end
end
