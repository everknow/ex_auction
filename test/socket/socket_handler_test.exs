defmodule ExAuction.SocketTests do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  describe "Socket handler tests" do
    setup do
      Process.register(self(), TestProcess)
      {:ok, _} = Application.ensure_all_started(:ex_auction)
      _pid = start_supervised!({GunServer, []})
      :ok
    end

    test "valid message" do
      original_message = "this is the message"
      GunServer.send_frame(%{"message" => original_message, "token" => "some token"})
      expected_message = "Received: " <> original_message
      assert_receive({:websocket_replied, ^expected_message}, 5000)
    end

    test "malformed message" do
      GunServer.send_frame("i am not a valid message")
      assert_receive({:websocket_replied, "unable to decode the payload"}, 5000)
    end

    test "payload with missing authorization token" do
      GunServer.send_frame(%{"message" => "some message"})
      assert_receive({:websocket_replied, "missing authorization token"}, 5000)
    end

    test "payload with missing message" do
      GunServer.send_frame(%{"token" => "some token"})
      assert_receive({:websocket_replied, "invalid payload"}, 5000)
    end
  end

  describe "GunServer tests" do
    setup do
      Process.register(self(), TestProcess)
      _pid = start_supervised!({GunServer, []})
      :ok
    end

    test "graceful exit" do
      GunServer.kill_client_process()
      assert_receive(:gunserver_killed, 5000)
    end

    test "websocket_info" do
      assert capture_log(fn ->
               assert :ok = GunServer.get_socket_info()
             end) =~ "bruno"
    end
  end
end
