import Config

config :ex_auction, ExAuction.Repo,
  database: "auction_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :ex_auction, :port, 8080
