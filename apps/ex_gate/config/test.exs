import Config

config :ex_gate, google_client_id: "test_id"

config :ex_gate,
  port: 9999,
  token: "token",
  tls: true

config :tesla, adapter: Tesla.Mock
