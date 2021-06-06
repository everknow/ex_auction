defmodule ExAuctionsAdmin.Router do
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

  forward("/api/v1/blind_auctions", to: ExAuctionsAdmin.BlindAuctions.V1.Receiver)

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
    send_resp(conn, 404, "404")
  end
end
