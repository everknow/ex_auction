defmodule Km.MixProject do
  use Mix.Project

  def project do
    [
      app: :km,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mnemo, "~> 0.1.2"},
      {:block_keys, "~> 0.1.8"},
      {:tesla, "~> 1.3"},
      {:ex_secp256k1, "~> 0.1.2"}
    ]
  end
end
