import Config

# ExGate
config :ex_gate, google_client_id: "test_id"

config :ex_gate,
  port: 9999,
  token: "token",
  tls: true

config :tesla, adapter: Tesla.Mock

# ExAuctionsManager
config :ex_auctions_manager, ExAuctionsManager.Repo,
  database: "auctions_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
