import Config

config :ex_auction, ExAuction.Repo,
  database: "auction_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :ex_auction, port: 9999, token: "token", tls: false
