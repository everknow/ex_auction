defmodule ExAuctionsDB.Bid do
  @moduledoc """
  Bid schema
  """
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsDB.{Auction, Bid, DB}

  require Logger

  @derive {Jason.Encoder, only: [:auction_id, :bid_value, :bidder]}
  schema "bids" do
    field(:bid_value, :integer)
    field(:bidder, :string)

    belongs_to(:auction, Auction)
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
    |> foreign_key_constraint(:auction_id)
  end
end
