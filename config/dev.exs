import Config

# ExGate
config :ex_gate, google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :ex_gate, port: 8080, token: "token", tls: false

# ExAuctionsDB
config :ex_auctions_manager, :port, 8081

# ExAuctionsAdmin
config :ex_auctions_admin, google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :ex_auctions_admin, port: 8082, token: "token", tls: false

# ExAuctionsDB
config :ex_auctions_db, ExAuctionsDB.Repo,
  database: "auctions",
  username: "reasonedart-pg-admin",
  password: "wagh9wrou@GNAF2shef",
  hostname: "34.107.97.226",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  ssl: true,
  ssl_opts: [
    cacertfile: "priv/server-ca.pem",
    keyfile: "priv/client-key.pem",
    certfile: "priv/client-cert.pem"
  ]
