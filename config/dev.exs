import Config

config :ex_auction, ExAuction.Repo,
  database: "auction_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :ex_auction, google_client_id: System.fetch_env!("GOOGLE_CLIENT_ID")

config :ex_auction, :port, 8080
config :ex_auction, token: "token", tls: false
