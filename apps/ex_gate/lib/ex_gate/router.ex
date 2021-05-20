defmodule ExGate.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    conn = put_resp_content_type(conn, "text/html")
    path = Application.app_dir(:ex_gate) <> "/priv/static/v1"
    send_file(conn, 200, "#{path}/index.html")
  end

  get "/auction" do
    conn = put_resp_content_type(conn, "text/html")
    path = Application.app_dir(:ex_gate) <> "/priv/static/v1"
    send_file(conn, 200, "#{path}/auction.html")
  end

  forward("/verify", to: ExGate.Login.V1.Receiver)

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
