defmodule ExGate.Router do
  use Plug.Router
  require Logger
  plug(:match)
  plug(Plug.Logger, log: :debug)
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Guardian.Plug.Pipeline,
    module: ExGate.Guardian,
    error_handler: ExGate.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})

  plug(:dispatch)

  get "/" do
    # For K8s healthy state
    send_resp(conn, 200, "OK")
  end

  # NON PROD
  get "/dev" do
    conn = put_resp_content_type(conn, "text/html")
    path = Application.app_dir(:ex_gate) <> "/priv/static/v1"
    send_file(conn, 200, "#{path}/index.html")
  end

  get "/dev/username" do
    conn = put_resp_content_type(conn, "text/html")
    path = Application.app_dir(:ex_gate) <> "/priv/static/v1"
    send_file(conn, 200, "#{path}/username.html")
  end

  get "/dev/auction" do
    conn = put_resp_content_type(conn, "text/html")
    path = Application.app_dir(:ex_gate) <> "/priv/static/v1"
    send_file(conn, 200, "#{path}/auction.html")
  end

  # --------------

  forward("/gate/login", to: ExGate.Login.V1.Receiver)
  forward("/gate/register", to: ExGate.Register.Receiver)

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
