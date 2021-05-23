defmodule ExAuctionsManager.Bids.V1.Receiver do
  @moduledoc """
  Admin UI receiver, version 1
  """
  use Plug.Router
  import Plug.Conn

  alias ExAuctionsManager.{Bid, DB}
  alias ExGate.WebsocketUtils

  require Logger

  require Logger

  plug(Plug.RequestId)

  plug(Guardian.Plug.Pipeline,
    module: ExGate.Guardian,
    error_handler: ExGate.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})
  plug(Guardian.Plug.EnsureAuthenticated)

  # to be removed in prod
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/:auction_id" do
    # TODO: move this in the configuration
    default_size = 10
    %{"auction_id" => auction_id} = conn.params
    page = Map.get(conn.params, "page", 0) |> String.to_integer()
    size = Map.get(conn.params, "size", default_size) |> String.to_integer()

    {bids, headers} = DB.list_bids(auction_id, page, size)

    conn
    |> inject_headers(headers)
    |> json_resp(200, bids)
  end

  post "/" do
    case valid_payload?(conn) do
      true ->
        %{"auction_id" => auction_id, "bid_value" => bid_value, "bidder" => bidder} = conn.params
        bid_value = maybe_convert(bid_value)
        auction_id = maybe_convert(auction_id)

        case DB.create_bid(auction_id, bid_value, bidder) do
          {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} ->
            WebsocketUtils.notify_bid(auction_id, bid_value)

            json_resp(conn, 201, %{auction_id: auction_id, bid_value: bid_value, bidder: bidder})

          {:error, %Ecto.Changeset{valid?: false, errors: errors}} ->
            Logger.error("auction #{}: bid #{} cannot be accepted. Reason: #{inspect(errors)}")
            reasons = errors |> Enum.map(fn {_, {reason, _}} -> reason end)

            json_resp(
              conn,
              422,
              %{auction_id: auction_id, bid_value: bid_value, bidder: bidder, reasons: reasons}
            )
        end

      false ->
        json_resp(conn, 400, "BAD REQUEST")
    end
  end

  defp json_resp(conn, status, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end

  defp maybe_convert("") do
    Logger.warn("empty")
    0
  end

  defp maybe_convert(value) when is_bitstring(value) do
    Logger.warn("string")
    String.to_integer(value)
  end

  defp maybe_convert(value) do
    Logger.warn("general")
    value
  end

  def inject_headers(conn, headers) do
    string_headers =
      headers |> Enum.map(fn {key, value} -> {key |> to_string(), value |> to_string()} end)

    %{conn | resp_headers: conn.resp_headers ++ Enum.to_list(string_headers)}
  end

  defp valid_payload?(conn) do
    Map.has_key?(conn.params, "auction_id") &&
      Map.has_key?(conn.params, "bid_value") &&
      Map.has_key?(conn.params, "bidder")
  end
end
