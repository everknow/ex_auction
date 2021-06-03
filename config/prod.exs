import Config

# ExGate
config :ex_gate, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_gate, port: 8080, token: "token", tls: false

# ExAuctionsDB
config :ex_auctions_manager, :port, 8081

config :ex_auctions_db, ExAuctionsDB.Repo,
  database: System.fetch_env!("DATABASE_NAME"),
  username: System.fetch_env!("DATABASE_USER"),
  password: System.fetch_env!("DATABASE_PASSWORD"),
  hostname: System.fetch_env!("DATABASE_HOSTNAME"),
  port: System.fetch_env!("DATABASE_PORT"),
  pool_size: 10,
  show_sensitive_data_on_connection_error: true,
  # This drive db creation for first time startup
  create: true

# ExAuctionsAdmin
config :ex_auctions_admin, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_auctions_admin, port: 8082, token: "token", tls: false
