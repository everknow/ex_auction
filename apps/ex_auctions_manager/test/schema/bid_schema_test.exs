defmodule ExAuctionsManager.BidSchemaTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB}

  describe "Schema tests" do
    setup do
      {:ok, %Auction{} = auction} = DB.create_auction(10.0, 8000)
      {:ok, %{auction: auction}}
    end

    test "bid creation success", %{auction: %Auction{id: auction_id}} do
      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 10.0,
                bidder: "some_bidder"
              }} = DB.create_bid(auction_id, 10.0, "some_bidder")
    end

    test "bids list", %{auction: %Auction{id: auction_id}} do
      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 12.0,
                bidder: "some_bidder"
              }} = DB.create_bid(auction_id, 12.0, "some_bidder")

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 14.0,
                bidder: "some_bidder2"
              }} = DB.create_bid(auction_id, 14.0, "some_bidder2")

      assert 2 == length(DB.list_bids(auction_id))
    end

    test "bids creation - 1 invalid", %{auction: %Auction{id: auction_id}} do
      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 11.0,
                bidder: "some_bidder"
              }} = DB.create_bid(auction_id, 11.0, "some_bidder")

      assert {:error, %Ecto.Changeset{valid?: false} = errors} =
               DB.create_bid(auction_id, 10.0, "some_bidder2")

      assert "bid 10.0 is below latest bid 11.0" in errors_on(errors).bid_value
    end
  end
end
