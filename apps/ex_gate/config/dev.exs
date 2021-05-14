import Config

config :ex_gate, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_gate, :port, 8080
config :ex_gate, token: "token", tls: false
