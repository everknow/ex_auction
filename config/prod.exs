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
  create: true

# ExAuctionsAdmin
config :ex_auctions_admin, google_client_id: System.get_env("GOOGLE_CLIENT_ID", "missing")

config :ex_auctions_admin, port: 8082, token: "token", tls: false

config :ex_contract_cache,
  base_uri: "https://everknow.it/web3",
  contract: "0xe04DCd6e51312E05b43466463687425Da3229cde",
  page_size: 10,
  interval_ms: 5000,
  redis_host: "localhost",
  redis_port: 6379,
  s3_base_uri: "https://art-test.s3-eu-west-1.amazonaws.com/",
  s3_interval_ms: 500_000,
  implementation: ExContractCache.Redis
