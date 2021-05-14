import Config

config :ex_auctions_manager,
  ecto_repos: [ExAuctionsManager.Repo]

import_config "#{Mix.env()}.exs"
