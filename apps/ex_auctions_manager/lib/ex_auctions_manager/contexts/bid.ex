defmodule ExAuctionsManager.Bid do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  schema "bids" do
    field(:auction_id, :string)
    field(:bid_value, :string)
    # Not sure if this is needed
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
  end
end
