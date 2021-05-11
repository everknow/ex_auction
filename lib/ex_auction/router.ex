defmodule ExAuction.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward("/v1", to: ExAuction.Login.V1.Receiver)
  # forward("/api/v1/protected", to: ExAuction.Protected.V1.Receiver)

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
