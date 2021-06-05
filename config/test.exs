import Config

# ExGate
config :ex_gate, google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :ex_gate, port: 9999, token: "token", tls: false

# ExAuctionsManager
config :ex_auctions_manager,
  port: 10000,
  token: "token"

# ExAuctionsAdmin
config :ex_auctions_admin,
  port: 10001,
  token: "token"

# ExAuctionsDB
config :ex_auctions_db, ExAuctionsDB.Repo,
  database: "auctions_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true
