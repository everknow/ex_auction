defmodule ExAuctionsManager.BidsEndpointTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB}
  alias ExAuctionsManager.TestHTTPClient

  describe "Bids list endpoint test" do
    test "/bids/:auction_id populated list" do
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

    test "/bids create bid", %{auction_id: auction_id} do
      bidder = "bidder"
      bid_value = 110
      new_bid_value = 120

      assert {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
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

      assert DB.list_bids(auction_id) |> length() == 2
    end

    test "/post create bid failure - unprocessable entity" do
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

      assert {:ok, %Tesla.Env{status: 422, body: body}} =
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

    test "/post create bid failure - 400 bad request" do
      assert {:ok, %Auction{id: auction_id}} =
               DB.create_auction(TestUtils.shift_datetime(TestUtils.get_now(), 0, 0, 0, 1), 100)

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

      :timer.sleep(1500)

      assert {:ok, %Tesla.Env{status: 400, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/bids/",
                 %{"bid_value" => new_bid_value, "bidder" => bidder}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert {:ok, %Tesla.Env{status: 400, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/bids/",
                 %{"auction_id" => auction_id, "bidder" => bidder}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert {:ok, %Tesla.Env{status: 400, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/bids/",
                 %{"auction_id" => auction_id, "bid_value" => new_bid_value}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )
    end
  end
end
