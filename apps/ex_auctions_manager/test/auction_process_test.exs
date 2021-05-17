defmodule ExAuctionsManager.AuctionProcessTest do
  use ExAuctionsManager.RepoCase, async: false

  import ExUnit.CaptureLog
  import Mock
  alias ExAuctionsManager.{AuctionsProcess, DB}

  describe "AuctionsProcess tests" do
    setup do
      auction_id = "1"
      start_supervised!({AuctionsProcess, [auction_id: auction_id]})

      {:ok, %{auction_id: auction_id}}
    end

    test "successful bid", %{auction_id: auction_id} do
      {:accepted, "50"} = AuctionsProcess.bid(auction_id, "50", "some_bidder")

      assert capture_log(fn ->
               {:rejected, "50", "50"} = AuctionsProcess.bid("1", "50", "some_bidder")
             end) =~ "rejected because it's below or equals the latest bid"
    end

    test "failing bid", %{auction_id: auction_id} do
      bid_value = "50"
      bidder = "some bidder"

      with_mock(DB, create_bid: fn _, _, _ -> {:error, %Ecto.Changeset{valid?: false}} end) do
        assert capture_log(fn ->
                 {:rejected, bid_value, "0"} = AuctionsProcess.bid(auction_id, bid_value, bidder)
               end) =~ "unable to bid #{bid_value} on auction #{auction_id} for user #{bidder}"
      end
    end
  end
end
