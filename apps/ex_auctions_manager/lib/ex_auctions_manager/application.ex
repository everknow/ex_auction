defmodule ExAuctionsManager.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        # This must come from config, so that it can be https on prod
        scheme: :http,
        plug: ExAuctionsManager.Router,
        port: Application.get_env(:ex_auctions_manager, :port, 8081)
      )
    ]

    opts = [strategy: :one_for_one, name: ExAuctionsManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
