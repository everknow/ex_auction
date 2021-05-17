defmodule ExAuctionsManager.Bid do
  @moduledoc """
  Bid schema
  """
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsManager.{Bid, DB}

  require Logger

  @derive {Jason.Encoder, only: [:auction_id, :bid_value, :bidder]}
  schema "bids" do
    field(:auction_id, :integer)
    field(:bid_value, :float)
    field(:bidder, :string)
  end

  def changeset(%__MODULE__{} = bid, attrs) do
    bid
    |> cast(attrs, [
      :auction_id,
      :bid_value,
      :bidder
    ])
    |> validate_required([
      :auction_id,
      :bid_value,
      :bidder
    ])
    |> validate_auction_existence(:auction_id)
    |> validate_bid(:bid_value)
  end

  defp validate_auction_existence(changeset, :auction_id = field, options \\ []) do
    validate_change(changeset, field, fn _, auction_value ->
      case DB.auction_exists?(auction_value) do
        true ->
          []

        false ->
          [
            {field, options[field] || "auction does not exist"}
          ]
      end
    end)
  end

  defp validate_bid(%Ecto.Changeset{valid?: false}, _, _) do
    # Skip if cs is not valid
    []
  end

  defp validate_bid(changeset, :bid_value = field, opts \\ []) do
    validate_change(changeset, field, fn _, bid_value ->
      auction_id = get_field(changeset, :auction_id)

      # I can assume that the auction exists
      case DB.get_latest_bid(auction_id) do
        nil ->
          []

        %Bid{bid_value: latest_bid} when latest_bid < bid_value ->
          []

        %Bid{bid_value: latest_bid} ->
          [
            {field, opts[field] || "bid #{bid_value} is below latest bid #{latest_bid}"}
          ]
      end
    end)
  end

  def get_auction_base(auction_id) do
  end
end
