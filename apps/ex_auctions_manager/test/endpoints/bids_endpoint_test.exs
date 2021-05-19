defmodule ExAuctionsManager.BidsEndpointTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB}
  alias ExAuctionsManager.TestHTTPClient

  describe "Bids list endpoint test" do
    test "/get empty list" do
      assert [] = DB.list_bids("1")
    end

    test "/get populated list" do
      assert {:ok, %Auction{id: auction_id}} =
               DB.create_auction(TestUtils.shift_datetime(TestUtils.get_now(), 5), 2)

      for elem <- 1..10 do
        bid_value = elem * 10
        bidder = "some bidder"

        {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
          DB.create_bid(auction_id, bid_value, bidder)
      end

      assert DB.list_bids(auction_id) |> length() == 10

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 200, body: body}} =
        TestHTTPClient.get("/api/v1/bids/#{auction_id}",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert 10 == body |> Jason.decode!() |> length()
    end
  end

  describe "Bid creation endpoint test" do
    setup do
      assert {:ok, %Auction{id: auction_id}} =
               DB.create_auction(TestUtils.shift_datetime(TestUtils.get_now(), 5), 100)

      {:ok, %{auction_id: auction_id}}
    end

    test "/post create bid", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 110
      new_bid_value = 120

      {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
        DB.create_bid(auction_id, bid_value, bidder)

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
                 "http://localhost:10000/api/v1/bids/",
                 %{"auction_id" => auction_id, "bid_value" => new_bid_value, "bidder" => bidder}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{"auction_id" => auction_id, "bid_value" => ^new_bid_value, "bidder" => ^bidder} =
               body |> Jason.decode!()

      assert DB.list_bids(auction_id) |> length() == 2
    end

    test "/post create bid failure" do
      bidder = "bidder"
      bid_value = 110
      new_bid_value = 120

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 500, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/bids/",
                 %{"auction_id" => -1, "bid_value" => new_bid_value, "bidder" => bidder}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{
               "auction_id" => -1,
               "bid_value" => ^new_bid_value,
               "bidder" => ^bidder,
               "reasons" => ["auction does not exist"]
             } = body |> Jason.decode!()
    end
  end
end
