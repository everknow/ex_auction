defmodule ExAuctionsManager.BidSchemaTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB}

  describe "Schema tests" do
    setup do
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 10)

      {:ok, %Auction{} = auction} = DB.create_auction(expiration_date, 10)
      {:ok, %{auction: auction}}
    end

    test "bid creation success", %{auction: %Auction{id: auction_id}} do
      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 10,
                bidder: "some_bidder"
              }} = DB.create_bid(auction_id, 10, "some_bidder")

      %Auction{id: ^auction_id, highest_bidder: "some_bidder", highest_bid: 10} =
        Auction |> Repo.get(auction_id)

      assert {
               :error,
               %Ecto.Changeset{valid?: false} = cs
             } = DB.create_bid(auction_id, 10, "some_bidder2")

      assert "bid value 10 is not bigger than highest bid 10" in errors_on(cs).bid_value

      %Auction{id: ^auction_id, highest_bidder: "some_bidder", highest_bid: 10} =
        Auction |> Repo.get(auction_id)
    end

    test "bid creation failure - non existing auction" do
      assert {:error, %Ecto.Changeset{valid?: false} = cs} =
               DB.create_bid(1, 9, "some_bidder") |> IO.inspect()

      assert "auction does not exist" in errors_on(cs).auction_id
    end

    test "bid creation failure - bid below auction base", %{auction: %Auction{id: auction_id}} do
      assert {:error, %Ecto.Changeset{valid?: false} = cs} =
               DB.create_bid(auction_id, 1, "some_bidder")

      assert "below auction base 10" in errors_on(cs).bid_value
    end

    test "bids list", %{auction: %Auction{id: auction_id} = auction} do
      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 12,
                bidder: "some_bidder"
              }} = DB.create_bid(auction_id, 12, "some_bidder")

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 14,
                bidder: "some_bidder2"
              }} = DB.create_bid(auction_id, 14, "some_bidder2")

      assert 2 == length(DB.list_bids(auction_id))
    end

    test "bids creation - non_existing auction" do
      assert {:error, %Ecto.Changeset{valid?: false} = cs} = DB.create_bid(1, 10, "some_bidder")

      assert "auction does not exist" in errors_on(cs).auction_id
    end
  end

  describe "demo test" do
    setup do
      # 4 seconds for testing purposes
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 0, 0, 10)
      {:ok, %Auction{} = auction} = DB.create_auction(expiration_date, 100)
      {:ok, %{auction: auction}}
    end

    test "scenario 1", %{auction: %Auction{id: auction_id}} do
      assert {:error, cs} = DB.create_bid(auction_id, 90, "bidder1")
      assert "below auction base 100" in errors_on(cs).bid_value

      assert {:ok, %Bid{bid_value: 120, bidder: "bidder1"}} =
               DB.create_bid(auction_id, 120, "bidder1")

      assert {:error, cs} = DB.create_bid(auction_id, 110, "bidder2")
      assert "bid value 110 is not bigger than highest bid 120" in errors_on(cs).bid_value

      assert {:ok, %Bid{bid_value: 130, bidder: "bidder2"}} =
               DB.create_bid(auction_id, 130, "bidder2")
    end
  end
end
