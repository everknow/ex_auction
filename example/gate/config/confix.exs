import Config

config :gateway, Gate.Guardian,
  issuer: "Gate",
  secret_key: "not secret, by config",
  secret_fetcher: Gate.SecretFetcher
