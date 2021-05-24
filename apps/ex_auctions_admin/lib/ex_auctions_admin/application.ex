defmodule ExAuctionsAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        # This must come from config, so that it can be https on prod
        scheme: :http,
        plug: ExAuctionsAdmin.Router,
        port: Application.get_env(:ex_auctions_admin, :port, 8082)
      )
    ]

    opts = [strategy: :one_for_one, name: ExAuctionsAdmin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
