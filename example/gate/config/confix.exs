import Config

config :gate, Gate.Guardian,
  issuer: "Gate",
  secret_key: "not secret, by config",
  secret_fetcher: Gate.SecretFetcher

config :gate,
  schema_parts: [
    Gate.Login.SchemaEntries
  ]

config :ex_json_schema,
  custom_format_validator: {Gate.CustomValidator, :validate}
