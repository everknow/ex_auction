import Config

config :ex_auction, ExAuction.Repo,
  database: "auction_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
