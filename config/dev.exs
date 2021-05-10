import Config

config :ex_auction, ExAuction.Repo,
  database: "auction_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
