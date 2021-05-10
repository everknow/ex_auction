defmodule ExAuction.SocketHandler do
  @moduledoc """
  Socket handler module. Skeleton, so far.

  A message **must** contain the auth token:

  %{
    "message" => %{},
    "token" => "token"
  }
  """
  @behaviour :cowboy_websocket
  require Logger

  def init(request, state) do
    # The state should be somehow loaded now
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    with {:ok, payload} <- decode_payload(message),
         true <- is_authenticated?(payload) do
      case payload do
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
        {:reply, {:text, "missing authorization token"}, state}
    end
  end

  def websocket_info(:ping, state) do
    # Generic catch all - maybe not needed, since the parser will only return
    # a json payload ?
    {:reply, :pong, state}
  end

  def websocket_info(info, state) do
    # Generic catch all - maybe not needed, since the parser will only return
    # a json payload ?
    {:reply, {:text, "error"}, state}
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
