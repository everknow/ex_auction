defmodule ExAuctionsManager.Repo do
  use Ecto.Repo,
    otp_app: :ex_gate,
    adapter: Ecto.Adapters.Postgres
end
