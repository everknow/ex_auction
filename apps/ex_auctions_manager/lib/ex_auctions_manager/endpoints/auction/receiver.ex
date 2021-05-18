defmodule ExAuctionsManager.Auctions.V1.Receiver do
  @moduledoc """
  Admin UI receiver, version 1
  """
  use Plug.Router

  use Plug.Debugger,
    otp_app: :ex_auctions_manager

  alias ExAuctionsManager.{Auction, DB}

  require Logger

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Guardian.Plug.Pipeline,
    module: ExGate.Guardian,
    error_handler: ExGate.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})
  plug(Guardian.Plug.EnsureAuthenticated)

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
    %{"auction_base" => auction_base, "expiration_date" => expiration_date} = conn.params

    {:ok, expiration_date, _} = expiration_date |> DateTime.from_iso8601()

    case DB.create_auction(expiration_date, auction_base) do
      {:ok, %Auction{}} ->
        json_resp(conn, 201, :created)

      {:error, %Ecto.Changeset{valid?: false, errors: errors}} ->
        Logger.error("auction #{}: bid #{} cannot be accepted. Reason: #{inspect(errors)}")
        # TODO: inspect changeset error to understand where is the error message and use the
        # latest_bid value
        IO.inspect(errors)
        json_resp(conn, 500, "unable to create auction")
    end
  end

  defp json_resp(conn, status, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "404")
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
