defmodule ExAuctionsManager.Repo.Migrations.AddBidsTable do
  use Ecto.Migration

  def change do
    create table("bids") do
      add :bid_value, :integer, null: false
      add :bidder, :string
      add :auction_id, references("auctions"), null: false
    end

    create unique_index("bids", [:auction_id, :bid_value])
  end
end
