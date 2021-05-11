defmodule GunServer do
  use GenServer

  require Logger

  @backoff_time 100

  def init(_) do
    Process.send_after(self(), :start, @backoff_time)
    {:ok, %{conn: nil, mon: nil, stream: nil, ready: false}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: GunServer)
  end

  @impl true
  def handle_info(:start, state) do
    Logger.warn("#{__MODULE__} Starting up")
    {:noreply, establishConnection(state)}
  end

  @impl true
  def handle_info({:gun_down, _conn, _ws, _closed, _, _}, state) do
    Logger.warn("#{__MODULE__} received message: :gun_down")
    closeConnection(state.conn, state.mon)
    {:noreply, establishConnection(state)}
  end

  @impl true
  def handle_info({:gun_ws, _conn, _ws, {:close, _close_code, _string}}, state) do
    Logger.warn("#{__MODULE__} Closing socket")
    closeConnection(state.conn, state.mon)
    {:noreply, establishConnection(state)}
  end

  # Coming from the socket server
  def handle_info({:gun_ws, _conn, _stream, {:text, message}}, state) do
    Process.send(TestProcess, {:websocket_replied, message}, [])
    {:noreply, state}
  end

  def handle_info({:gun_ws, _conn, _ws, :close}, state) do
    Logger.warn("#{__MODULE__} Closing socket")
    closeConnection(state.conn, state.mon)
    {:noreply, establishConnection(state)}
  end

  def handle_info({:gun_upgrade, _conn, _mon, _type, _info}, state) do
    Logger.warn(
      "#{__MODULE__} websocket connection updateded and ready to be used upgrade complete and ready to be used"
    )

    {:noreply, markConnectionAsReady(state)}
  end

  @impl true
  def handle_info({:send_message, msg}, %{ready: false} = state) do
    Logger.warn(
      "#{__MODULE__} received payload to send to the server #{inspect(msg)} with server not ready. Retrying..."
    )

    Process.send_after(self(), {:send_message, msg}, 200)
    {:noreply, state}
  end

  @impl true
  def handle_info({:send_message, msg}, %{conn: conn, ready: true} = state) when is_map(msg) do
    Logger.warn("#{__MODULE__} received payload to send to the server #{inspect(msg)}")
    :gun.ws_send(conn, {:text, msg |> Jason.encode!()})
    {:noreply, state}
  end

  @impl true
  def handle_info({:send_message, msg}, %{conn: conn, ready: true} = state)
      when is_bitstring(msg) do
    Logger.warn("#{__MODULE__} received malformed payload to send to the server #{inspect(msg)}")
    :gun.ws_send(conn, {:text, msg})
    {:noreply, state}
  end

  # Server reply: :pong
  @impl true
  def handle_info(:pong, state) do
    Logger.warn("#{__MODULE__} :: received :pong from socket server")
    Process.send(TestProcess, :pong_received, [])
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.debug("#{__MODULE__} nicely exited with reason: #{inspect(reason)}")
    Process.send(TestProcess, :gunserver_killed, [])
    {:noreply, state}
  end

  defp closeConnection(conn, mref) do
    Logger.warn("#{__MODULE__} closing connection")
    _ = :erlang.demonitor(mref)
    _ = :gun.close(conn)
    _ = :gun.flush(conn)
  end

  defp create_gun_client(server, port, transport_flag) do
    opts = %{retry: 0}

    if transport_flag do
      opts = Map.put_new(opts, :transport, :tls)
    end

    {:ok, pid} =
      :gun.open(
        server,
        port,
        opts
      )
  end

  def markConnectionAsReady(state) do
    Map.update(state, :ready, true, fn _ -> true end)
  end

  defp establishConnection(state) do
    token = Application.get_env(:app, :token)
    server = "localhost" |> to_char_list()

    port = Application.get_env(:ex_auction, :port, 8080)
    tls_flag = Application.get_env(:ex_auction, :tls, false)

    with {:ok, conn_pid} <- create_gun_client(server, port, tls_flag) do
      true = Process.register(conn_pid, GunClientProcess)
      Logger.warn("Client created: #{inspect(conn_pid)}")
      {:ok, protocol} = :gun.await_up(conn_pid)
      Logger.warn("Client returned #{inspect(protocol)}")
      mon = Process.monitor(conn_pid)
      # TODO: maybe this could come from conf ?
      path = "/ws" |> to_charlist()

      Logger.warn("Client monitored")

      stream =
        :gun.ws_upgrade(conn_pid, path, [
          {"Authorization", "Bearer #{token}"}
        ])

      %{state | conn: conn_pid, mon: mon, stream: stream, ready: false}
    else
      e ->
        Logger.warn("[#{__MODULE__}] Invalid info #{inspect(e)}")
        %{state | conn: nil, mon: nil, stream: nil, ready: false}
    end
  end

  # Public test api
  def send_message(msg) do
    :ok = Process.send(GunServer, {:send_message, msg}, [])
  end

  def kill_client_process do
    case GunClientProcess |> Process.whereis() do
      nil ->
        :timer.sleep(@backoff_time)
        kill_client_process()

      pid ->
        pid
        |> Process.exit(:kill)
    end
  end
end
