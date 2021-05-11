defmodule ExAuction.SocketTests do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

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

    test "malformed message" do
      GunServer.send_message("i am not a valid message")
      assert_receive({:websocket_replied, "unable to decode the payload"}, 5000)
    end

    test "payload with missing authorization token" do
      GunServer.send_message(%{"message" => "some message"})
      assert_receive({:websocket_replied, "missing authorization token"}, 5000)
    end

    test "payload with missing message" do
      GunServer.send_message(%{"token" => "some token"})
      assert_receive({:websocket_replied, "invalid payload"}, 5000)
    end
  end
end
