defmodule ExAuction.Bid.V1.Receiver do
  use Plug.Router

  alias ExAuction.Bid.Handler

  require Logger

  plug(Guardian.Plug.Pipeline,
    module: ExAuction.Guardian,
    error_handler: ExAuction.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})
  plug(Guardian.Plug.EnsureAuthenticated)

  plug(Plug.Logger)

  # to be removed in prod
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/" do
    payload = conn.params

    payload
    |> execute_bid()
    |> (&create_response(conn, &1)).()
  end

  defp execute_bid(bid_payload) do
    case Handler.bid(bid_payload) do
      true -> {200, %{"bid" => "success"}}
      false -> {500, %{"bid" => "failure"}}
    end
  end

  defp create_response(conn, {status, response_payload}) do
    json_resp(conn, status, response_payload)
  end

  defp json_resp(conn, status \\ 200, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end
end
