defmodule ExContractCache.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_host = Application.fetch_env!(:ex_contract_cache, :redis_host)
    redis_port = Application.fetch_env!(:ex_contract_cache, :redis_port)

    children = [
      {Redix, [host: redis_host, port: redis_port, name: RedisInstance]},
      {ExContractCache.TraverseAndAggregate, []},
      {ExContractCache.SortAgent, []},
      Plug.Cowboy.child_spec(
        # This must come from config, so that it can be https on prod
        scheme: Application.fetch_env!(:ex_contract_cache, :scheme),
        plug: ExContractCache.Router,
        port: Application.fetch_env!(:ex_contract_cache, :port)
      )
    ]

    opts = [strategy: :one_for_one, name: ExContractCache.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
