import Config

# ExGate
config :ex_gate, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_gate, port: 9999, token: "token", tls: false

# ExAuctionsManager
config :ex_auctions_manager,
  port: 10000,
  token: "token"

config :ex_auctions_manager, ExAuctionsManager.Repo,
  database: "auctions_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true

# ExContractCache
config :ex_contract_cache,
  google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_contract_cache,
  port: 10002,
  token: "token",
  tls: false,
  scheme: :http

config :ex_contract_cache,
  base_uri: "https://everknow.it/web3",
  contract: "0xe04DCd6e51312E05b43466463687425Da3229cde",
  headers: [{"Accept", "application/json"}],
  page_size: 10,
  time: 5000,
  redis_host: "localhost",
  redis_port: 6379
