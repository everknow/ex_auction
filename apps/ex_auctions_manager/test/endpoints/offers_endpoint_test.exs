defmodule ExAuctionsDB.OffersEndpointTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{Auction, Bid, DB}

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
      # None is returned, since ^ returns only bids
      assert length(results) == 0
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
               "reasons" => %{"auction_id" => "auction does not exist"}
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

    test "/offers create offer error - bid below auction base", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 90

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
                   "auction_id" => auction_id,
                   "bid_value" => bid_value,
                   "bidder" => bidder
                 }
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{"reasons" => %{"bid_value" => "below auction base"}} = Jason.decode!(body)
    end

    test "/offers create offer error - bid below highest bid", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 110

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
                   "auction_id" => auction_id,
                   "bid_value" => 109,
                   "bidder" => bidder
                 }
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{"reasons" => %{"bid_value" => "below highest bid"}} = Jason.decode!(body)
    end
  end
end
