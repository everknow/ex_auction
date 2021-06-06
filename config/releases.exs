import Config

# ExGate
config :ex_gate, google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :ex_gate, port: 8080, token: "token", tls: false

# ExAuctionsDB
config :ex_auctions_manager, :port, 8081

config :ex_auctions_db, ExAuctionsDB.Repo,
  database: System.get_env("DATABASE_NAME", "missing"),
  username: System.get_env("DATABASE_USER", "missing"),
  password: System.get_env("DATABASE_PASSWORD", "missing"),
  hostname: System.get_env("DATABASE_HOSTNAME", "missing"),
  port: System.get_env("DATABASE_PORT", "0"),
  pool_size: 10,
  show_sensitive_data_on_connection_error: true,
  # This drive db creation for first time startup
  create: true,
  ssl: true,
  ssl_opts: [
    cacertfile: "/etc/rart-postgres-certs/server-ca.pem",
    keyfile: "/etc/rart-postgres-certs/client-key.pem",
    certfile: "/etc/rart-postgres-certs/client-cert.pem"
  ]

# ExAuctionsAdmin
config :ex_auctions_admin, google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :ex_auctions_admin, port: 8082, token: "token", tls: false
