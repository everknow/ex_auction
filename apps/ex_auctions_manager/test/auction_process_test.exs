defmodule ExAuctionsManager.AuctionProcessTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias ExAuctionsManager.AuctionsProcess

  describe "" do
    test "" do
      _pid = start_supervised!({AuctionsProcess, [auction_id: 1]})

      {:accepted, "50"} = AuctionsProcess.bid(1, "50")

      assert capture_log(fn ->
               {:rejected, "50", "50"} = AuctionsProcess.bid(1, "50")
             end) =~ "rejected because it's below or equals the latest bid"
    end
  end
end
