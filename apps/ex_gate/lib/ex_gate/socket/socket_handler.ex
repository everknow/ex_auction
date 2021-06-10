defmodule ExGate.SocketHandler do
  @moduledoc """
  Socket handler module. Skeleton, so far.

  A message **must** contain the auth token:

  %{
    "message" => %{},
    "token" => "token"
  }
  """
  @behaviour :cowboy_websocket

  alias ExGate.WebsocketUtils
  require Logger

  def init(request, _opts) do
    {:cowboy_websocket, request, %{subscriptions: []}}
  end

  # When connection is established
  def websocket_init(state) do
    {:ok, state}
  end

  # coveralls-ignore-start
  def websocket_info(msg, state) do
    Logger.debug("#{__MODULE__} generic websocket_info invoked: #{msg}")
    {:reply, {:text, msg}, state}
  end

  # coveralls-ignore-stop

  def websocket_terminate(_reason, _req, %{subscriptions: subscriptions} = state) do
    subscriptions |> Enum.each(&:pg2.leave(&1, self()))
    :ok
  end

  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle({:text, message}, state) do
    case decode_payload(message) do
      {:ok, %{"subscribe" => auction_id}} ->
        # Maybe check if the auction exists
        WebsocketUtils.register_subscription(auction_id, self())
        Logger.info("Subscribed to auction #{auction_id}")

        Map.put(state, :subscriptions, [auction_id])

        {:reply, {:text, "subscribed"}, state}

      {:ok, %{"user_identification" => user_id}} ->
        Logger.info("Received user identification")
        WebsocketUtils.register_user_identity(user_id, self())

        {:reply, {:text, "user identification received"}, state}

      {:ok, different_message} ->
        Logger.info("unrecognized message #{inspect(different_message)}")
        {:reply, {:text, "unrecognized_message"}, state}

      {:error, offending_message} ->
        Logger.error("unable to decode message: #{inspect(offending_message)}")
        {:reply, {:text, "unable to decode the message payload"}, state}
    end
  end

  defp decode_payload(payload) do
    payload
    |> Jason.decode()
  end
end
