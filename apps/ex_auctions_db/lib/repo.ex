defmodule ExAuctionsDB.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :ex_auctions_db,
    adapter: Ecto.Adapters.Postgres
end
