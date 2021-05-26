defmodule ExContractCache.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Redix, [host: "localhost", port: 6379, name: RedixInstance]},
      {ExContractCache.TraverseAndAggregate, []},
      Plug.Cowboy.child_spec(
        # This must come from config, so that it can be https on prod
        scheme: :http,
        plug: ExContractCache.Router,
        port: Application.get_env(:ex_contract_cache, :port, 8083)
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExContractCache.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
