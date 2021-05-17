defmodule ExAuctionsManager.SchemaTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Bid, DB}

  describe "Schema tests" do
    test "bid creation success" do
      assert {:ok,
              %Bid{
                auction_id: "1",
                bid_value: "10",
                bidder: "some_bidder"
              }} = DB.create_bid("1", "10", "some_bidder")
    end

    test "bid creation error" do
      assert {:error, %Ecto.Changeset{} = error} = DB.create_bid(1, "10", "some_bidder")

      assert "is invalid" in errors_on(error).auction_id
    end

    test "bids list" do
      assert {:ok,
              %Bid{
                auction_id: "1",
                bid_value: "10",
                bidder: "some_bidder"
              }} = DB.create_bid("1", "10", "some_bidder")

      assert {:ok,
              %Bid{
                auction_id: "1",
                bid_value: "11",
                bidder: "some_bidder2"
              }} = DB.create_bid("1", "11", "some_bidder2")

      assert 2 == length(DB.list_bids("1"))
    end
  end
end
