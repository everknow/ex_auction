import Config

config :ex_auction, ecto_repos: [ExAuction.Repo]

config :ex_auction, ExAuction.Guardian,
  issuer: "ExAuction",
  secret_key: "not secret, by config",
  secret_fetcher: ExAuction.SecretFetcher

# Schemas - this should be reasonably common to all the envs
config :ex_auction,
  schema_parts: [
    ExAuction.Login.SchemaEntries,
    ExAuction.Dummy.SchemaEntries
  ]

config :ex_json_schema,
  custom_format_validator: {ExAuction.CustomValidator, :validate}

import_config "#{Mix.env()}.exs"
