defmodule ExAuctionsManager.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :ex_auctions_manager,
    adapter: Ecto.Adapters.Postgres
end
