defmodule Gate.Router do

  require Logger
  use Plug.Router

  plug(Plug.Logger, log: :debug)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward("/gate/v1/login", to: Gate.Login.V1.Receiver)
  forward("/gate/v1/protected", to: Gate.Protected.V1.Receiver)

  match _ do
    case conn.request_path do
      "/" ->
        # for healthcheck
        send_resp(conn, 200, "ok")

      path ->
        send_resp(conn, 404, "#{inspect(path)}")
    end
  end

end
