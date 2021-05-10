defmodule ExAuction.Repo do
  use Ecto.Repo,
    otp_app: :ex_auction,
    adapter: Ecto.Adapters.Postgres
end
