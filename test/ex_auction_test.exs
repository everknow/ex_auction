defmodule ExAuction.SocketTests do
  use ExUnit.Case, async: true

  describe "" do
    setup do
      Process.register(self(), TestProcess)
      {:ok, _} = Application.ensure_all_started(:ex_auction)
      _pid = start_supervised!({GunServer, []})
      :ok
    end

    test "valid message" do
      original_message = "this is the message"
      GunServer.send_message(%{"message" => original_message, "token" => "some token"})
      expected_message = "Received: " <> original_message
      assert_receive({:websocket_replied, ^expected_message}, 5000)
    end
  end
end
