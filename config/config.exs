import Config

# ExGate configuration
config :ex_gate, ecto_repos: [ExGate.Repo]

config :ex_gate, ExGate.Guardian,
  issuer: "ExGate",
  secret_key: "not secret, by config",
  secret_fetcher: ExGate.SecretFetcher

# Schemas - this should be reasonably common to all the envs
config :ex_gate,
  schema_parts: [
    ExGate.Login.SchemaEntries,
    ExGate.Dummy.SchemaEntries
  ]

config :ex_json_schema,
  custom_format_validator: {ExGate.CustomValidator, :validate}

import_config "#{Mix.env()}.exs"
