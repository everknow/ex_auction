defmodule ExAuctionsManager.Bids.V1.Receiver do
  @moduledoc """
  Admin UI receiver, version 1
  """
  use Plug.Router

  alias ExAuctionsManager.{Bid, DB, AuctionsProcess}
  alias ExGate.WebsocketUtils

  require Logger

  require Logger

  plug(Plug.RequestId)

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

  get "/:auction_id" do
    %{"auction_id" => auction_id} = conn.params
    auction_id = auction_id |> String.to_integer()
    bids = DB.list_bids(auction_id)
    json_resp(conn, 200, bids)
  end

  post "/" do
    %{"auction_id" => auction_id, "bid_value" => bid_value, "bidder" => bidder} = conn.params

    case DB.create_bid(auction_id, bid_value, bidder) do
      {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} ->
        WebsocketUtils.notify_listeners(
          auction_id,
          %{reason: "a new bid has just been created", auction_id: auction_id}
        )

        json_resp(conn, 200, bid_value)

      {:error, %Ecto.Changeset{valid?: false, errors: errors}} ->
        Logger.error("auction #{}: bid #{} cannot be accepted. Reason: #{inspect(errors)}")

        json_resp(
          conn,
          500,
          %{status: :rejected, bid: bid_value}
        )
    end
  end

  defp json_resp(conn, status, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end
end
