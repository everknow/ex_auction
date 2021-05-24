defmodule ExAuctionsManager.Bids.V1.Handler do
  alias ExAuctionsManager.{Bid, DB}
  alias ExGate.WebsocketUtils

  require Logger

  def list_bids(auction_id, page, size) do
    {bids, headers} = DB.list_bids(auction_id, page, size)
  end

  def create_bid(auction_id, bid_value, bidder) do
    auction = DB.get_auction(auction_id)

    case DB.create_bid(auction_id, bid_value, bidder) do
      {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} ->
        WebsocketUtils.notify_bid(auction_id, bid_value)
        {:ok, :created}

      {:error, %Ecto.Changeset{valid?: false, errors: errors}} ->
        Logger.error("auction #{}: bid #{} cannot be accepted. Reason: #{inspect(errors)}")

        reason = format_error_messages(errors)
        {:error, reason}
    end
  end

  defp format_error_messages(errors) do
    errors |> Enum.map(fn {key, {reason, _}} -> {key, reason} end) |> Enum.into(%{})
  end
end
