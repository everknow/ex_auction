defmodule ExAuctionsManager.OffersEndpointTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB}

  describe "Offers endpoint" do
    setup do
      assert {:ok, %Auction{id: auction_id}} =
               DB.create_auction(TestUtils.shift_datetime(TestUtils.get_now(), 5), 100, true)

      {:ok, %{auction_id: auction_id}}
    end

    test "/offers create offer", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 110
      new_bid_value = 120

      assert {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
               DB.create_bid(auction_id, bid_value, bidder, true)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 201, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/offers/",
                 %{
                   "auction_id" => auction_id,
                   "bid_value" => new_bid_value,
                   "bidder" => bidder
                 }
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{
               "auction_id" => auction_id,
               "bid_value" => new_bid_value,
               "bidder" => bidder
             } ==
               body |> Jason.decode!()

      assert {results, _} = DB.list_bids(auction_id)
      assert length(results) == 2
    end

    test "/offers create offer error", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 110
      new_bid_value = 120

      assert {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
               DB.create_bid(auction_id, bid_value, bidder, true)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 422, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/offers/",
                 %{
                   "auction_id" => -1,
                   "bid_value" => new_bid_value,
                   "bidder" => bidder
                 }
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{
               "auction_id" => -1,
               "bid_value" => new_bid_value,
               "bidder" => bidder,
               "reasons" => ["auction does not exist"]
             } ==
               body |> Jason.decode!()
    end

    test "/offers create offer error - invalid payload", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 110
      new_bid_value = 120

      assert {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
               DB.create_bid(auction_id, bid_value, bidder, true)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 400}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/offers/",
                 %{
                   "bid_value" => new_bid_value,
                   "bidder" => bidder
                 }
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )
    end
  end
end
