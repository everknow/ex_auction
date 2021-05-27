import Config

# Generic logger level
config :logger, level: :info

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

# ExContractCache
config :ex_contract_cache,
  google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_contract_cache,
  port: 8083,
  token: "token",
  tls: false,
  scheme: :http

config :ex_contract_cache,
  memorystore_adapter: ExContractCache.MemoryStore,
  base_uri: "https://everknow.it/web3",
  contract: "0xe04DCd6e51312E05b43466463687425Da3229cde",
  headers: [{"Accept", "application/json"}],
  page_size: 10,
  time: 5000,
  redis_host: "localhost",
  redis_port: 6379
