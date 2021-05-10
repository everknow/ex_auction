import Config

config :ex_auction, ecto_repos: [ExAuction.Repo]

import_config "#{Mix.env()}.exs"
