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

  get "/" do
    json_resp(conn, 200, DB.list_auctions())
  end

  post "/" do
    %{"auction_base" => auction_base, "expiration_date" => expiration_date} = conn.params

    {:ok, expiration_date, _} = expiration_date |> DateTime.from_iso8601()
    auction_base = auction_base |> maybe_convert()

    case DB.create_auction(expiration_date, auction_base) do
      {:ok, %Auction{id: auction_id, expiration_date: exp, auction_base: auction_base}} ->
        json_resp(conn, 201, %{
          auction_id: auction_id,
          expiration_date: exp,
          auction_base: auction_base
        })

      {:error, %Ecto.Changeset{valid?: false, errors: errors}} ->
        reasons = errors |> Enum.map(fn {_, {reason, _}} -> reason end)

        json_resp(conn, 422, %{reasons: reasons})
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

  defp maybe_convert("") do
    Logger.warn("empty")
    0
  end

  defp maybe_convert(value) when is_bitstring(value) do
    Logger.warn("string")
    String.to_integer(value)
  end

  defp maybe_convert(value) do
    value
  end
end
