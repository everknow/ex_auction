defmodule ExAuctionsManager.Router do
  use Plug.Router
  plug(Plug.Logger, log: :debug)
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward("/api/v1/users", to: ExAuctionsManager.Users.V1.Receiver)
  forward("/api/v1/offers", to: ExAuctionsManager.Offers.V1.Receiver)
  forward("/api/v1/auctions", to: ExAuctionsManager.Auctions.V1.Receiver)
  forward("/api/v1/bids", to: ExAuctionsManager.Bids.V1.Receiver)
  # forward("/api/v1/nfts", to: ExContractCache.Rest.V1.Receiver)

  require Logger

  get "/" do
    # For K8s healthy state
    send_resp(conn, 200, "OK")
  end

  # Two endpoints for K8s probes: liveness and readyness
  get "/live" do
    send_resp(conn, 200, "OK")
  end

  get "/ready" do
    send_resp(conn, 200, "OK")
  end

  match _ do
    Logger.info("#{__MODULE__}: #{inspect(conn.path_info)}")
    send_resp(conn, 404, "404")
  end
end
