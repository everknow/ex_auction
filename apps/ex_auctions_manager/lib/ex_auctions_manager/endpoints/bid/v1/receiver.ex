defmodule ExAuctionsManager.AdminUI.V1.Receiver do
  @moduledoc """
  Admin UI receiver, version 1
  """
  use Plug.Router

  alias ExAuctionsManager.{Bid, DB, AuctionsProcess}

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

  get "/bids/:auction_id" do
    %{"auction_id" => auction_id} = conn.params
    # TODO: this should go through the AuctionProcess genserver
    bids = DB.list_bids(auction_id)
    json_resp(conn, 200, bids)
  end

  post "/bid" do
    %{"auction_id" => auction_id, "bid_value" => bid_value, "bidder" => bidder} = conn.params

    # DANGEROUS: ideally this could be exploited to spawn multiple processes !
    with false <- AuctionsProcess.ready?(auction_id) do
      # NOTE: a failure here could represent a critical problem
      :started = AuctionsProcess.spawn(auction_id)
    end

    case AuctionsProcess.bid(auction_id, bid_value, bidder) do
      {:accepted, ^bid_value} ->
        json_resp(conn, 200, bid_value)

      {:rejected, ^bid_value, latest_bid} ->
        json_resp(conn, 500, %{status: :rejected, bid: bid_value, latest_bid: latest_bid})
    end

    json_resp(conn, 200, %{accepted: true})
  end

  defp json_resp(conn, status, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end
end
