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
    cacertfile: "/etc/reasoned-postgres-certs/server-ca.pem",
    keyfile: "/etc/reasoned-postgres-certs/client-key.pem",
    certfile: "/etc/reasoned-postgres-certs/client-cert.pem"
  ]

# ExAuctionsAdmin
config :ex_auctions_admin, google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :ex_auctions_admin, port: 8082, token: "token", tls: false

config :ex_contract_cache,
  base_uri: System.get_env("CONTRACT_BASE_URI", "missing"),
  contract: System.get_env("CONTRACT_ADDRESS", "missing"),
  page_size: System.get_env("CONTRACT_PAGE_SIZE", "-1") |> String.to_integer(),
  interval_ms: System.get_env("CONTRACT_CACHE_INTERVAL_MS", "-1") |> String.to_integer(),
  redis_host: System.get_env("REDIS_HOST", "missing"),
  redis_port: System.get_env("REDIS_PORT", "-1") |> String.to_integer(),
  s3_base_uri: System.get_env("CONTRACT_S3_BASE_URI", "missing"),
  s3_interval_ms: System.get_env("CONTRACT_S3_INTERVAL_MS", "-1") |> String.to_integer(),
  implementation: ExContractCache.Redis
