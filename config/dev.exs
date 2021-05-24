import Config

# ExGate
config :ex_gate, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_gate, port: 8080, token: "token", tls: false

# ExAuctionsManager
config :ex_auctions_manager, :port, 8081

config :ex_auctions_manager, ExAuctionsManager.Repo,
  database: "auctions_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

# ExAuctionsAdmin
config :ex_auctions_admin, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_auctions_admin, port: 8082, token: "token", tls: false
