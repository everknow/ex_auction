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
      GunServer.ping_server()
      assert_receive(:pong_received, 5000)
    end
  end
end
