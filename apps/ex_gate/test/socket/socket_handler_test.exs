defmodule ExGate.SocketTests do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  describe "Socket handler tests" do
    setup do
      Process.register(self(), TestProcess)
      {:ok, _} = Application.ensure_all_started(:ex_gate)
      _pid = start_supervised!({GunServer, []})
      :ok
    end

    test "subscription message" do
      GunServer.send_frame(%{"subscribe" => 1})
      expected_message = "Received: 1"
      assert_receive({:websocket_replied, "subscribed"}, 5000)
    end

    test "malformed message" do
      GunServer.send_frame("i am not a valid message")
      assert_receive({:websocket_replied, "unable to decode the message payload"}, 5000)
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
  end
end
