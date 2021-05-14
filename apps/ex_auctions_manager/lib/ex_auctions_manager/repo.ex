defmodule ExAuctionsManager.Repo do
  use Ecto.Repo,
    otp_app: :ex_auctions_manager,
    adapter: Ecto.Adapters.Postgres
end
