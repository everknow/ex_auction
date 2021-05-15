defmodule ExAuctionsManager.BidEndpointTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Bid, DB}
  alias ExAuctionsManager.TestHTTPClient

  import ExUnit.CaptureLog

  describe "Bid endpoint test" do
    test "/get empty list" do
      assert [] = DB.list_bids("1")
    end

    test "/get populated list" do
      auction_id = "1"

      for elem <- 1..10 do
        bid_value = (elem * 10) |> to_string()
        bidder = "some bidder"

        {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
          DB.create_bid(auction_id, bid_value, bidder)
      end

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 200, body: body}} =
        Tesla.client([])
        |> Tesla.get("http://localhost:10000/api/v1/bids/1",
          headers: [
            {"authorization",
             "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjEwOTU5MzIsImlhdCI6MTYyMTA5MjMzMiwiaXNzIjoiRXhHYXRlIiwianRpIjoiN2RkMDBkZDEtZDQ2MS00YTU1LTkyN2ItNGI4ZWUxZjQzMjllIiwibmJmIjoxNjIxMDkyMzMxLCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.U33JuUNB1TN1Ru3lq-XiA7P8rsDreJ0MX3s4C6selYHNXJL6dOKPmEhxBTpSHE1NtSbNgbw_9hwDOdXRsmKNWA"}
          ]
        )

      assert 10 == body |> Jason.decode!() |> length()
    end
  end
end
