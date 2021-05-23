defmodule ExAuctionsManager.BidsEndpointTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB}
  alias ExAuctionsManager.TestHTTPClient

  describe "Bids list endpoint test" do
    test "get populated list" do
      assert {:ok, %Auction{id: auction_id}} =
               DB.create_auction(TestUtils.shift_datetime(TestUtils.get_now(), 5), 2)

      page_size = 2
      page = 1

      for elem <- 1..10 do
        bid_value = elem * 10
        bidder = "some bidder"

        {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
          DB.create_bid(auction_id, bid_value, bidder)
      end

      assert {results, _} = DB.list_bids(auction_id, 1, 2)
      assert length(results) == 2

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 200, body: body, headers: headers}} =
               TestHTTPClient.get("/api/v1/bids/#{auction_id}?page=#{page}&size=#{page_size}",
                 headers: [
                   {"authorization", "Bearer #{token}"}
                 ]
               )

      assert page_size == body |> Jason.decode!() |> length()

      assert {"prev_page", "0"} in headers
      assert {"next_page", "2"} in headers
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

      assert {results, _} = DB.list_bids(auction_id)
      assert length(results) == 2
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

    test "/post create bid failure - expired auction" do
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

      assert {:ok, %Tesla.Env{status: 422, body: body}} =
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

      assert %{
               "auction_id" => ^auction_id,
               "bid_value" => ^new_bid_value,
               "bidder" => ^bidder,
               "reasons" => ["auction is expired"]
             } = body |> Jason.decode!()
    end
  end
end
