import Config

config :ex_auction, ExAuction.Repo,
  database: "auction_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :ex_auction, google_client_id: "test_id"

config :ex_auction,
  port: 9999,
  token: "token",
  tls: true

config :tesla, adapter: Tesla.Mock
