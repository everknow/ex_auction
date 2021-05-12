import Config

config :ex_auction, ecto_repos: [ExAuction.Repo]

config :ex_auction, ExAuction.Guardian,
  issuer: "ExAuction",
  secret_key: "not secret, by config",
  secret_fetcher: ExAuction.SecretFetcher

import_config "#{Mix.env()}.exs"
