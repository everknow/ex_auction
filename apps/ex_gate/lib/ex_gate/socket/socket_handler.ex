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

  def websocket_init(state) do
    {:ok, state}
  end

  # coveralls-ignore-start
  def websocket_info(info, state) do
    Logger.debug("#{__MODULE__} websocket_info invoked")
    {:reply, {:text, "ok"}, state}
  end

  # coveralls-ignore-stop

  def websocket_terminate(_reason, _req, %{subscriptions: subscriptions} = state) do
    subscriptions |> Enum.each(&:pg2.leave(&1, self()))
    :ok
  end

  def websocket_handle({:text, message}, state) do
    with {:ok, payload} <- decode_payload(message),
         true <- is_authenticated?(payload) do
      case payload do
        %{"subscribe" => auction_id} ->
          Logger.info("Subscribing to auction #{auction_id}")

          WebsocketUtils.register_subscription(auction_id, self())
          Logger.info("Subscribed to auction #{auction_id}")

          {:reply, {:text, Jason.encode!(%{ok: "subscribed"})},
           Map.put(state, :subscriptions, [auction_id])}

        %{"message" => message} ->
          Logger.debug("Message parsed")
          {:reply, {:text, "Received: " <> message}, state}

        otherwise ->
          Logger.error("invalid payload: #{inspect(otherwise)}")
          {:reply, {:text, "invalid payload"}, state}
      end
    else
      false ->
        Logger.error("Missing authorization token")
        {:reply, {:text, "missing authorization token"}, state}

      otherwise ->
        Logger.error("unable to decode the payload")
        {:reply, {:text, "unable to decode the payload"}, state}
    end
  end

  defp decode_payload(payload) do
    payload
    |> Jason.decode()
  end

  defp is_authenticated?(%{"token" => token}) do
    # This will execute the token verification and accordingly return true or false
    true
  end

  defp is_authenticated?(_) do
    false
  end
end
