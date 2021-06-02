defmodule ExAuctionsDB.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ExAuctionsDB.Repo, []}
    ]

    opts = [strategy: :one_for_one, name: ExAuctionsDB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
