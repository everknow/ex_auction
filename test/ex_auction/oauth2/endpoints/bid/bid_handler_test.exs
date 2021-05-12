defmodule ExAuction.Bid.Handler.Tests do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExAuction.GoogleClient
  alias ExAuction.Bid.Handler

  import ExUnit.CaptureLog
  import Mock

  describe "" do
    test "" do
      payload = %{"bid" => "1"}
      Handler.bid(payload)
    end
  end
end
