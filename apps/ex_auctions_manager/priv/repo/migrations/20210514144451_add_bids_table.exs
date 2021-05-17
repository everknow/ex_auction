defmodule ExAuctionsManager.Repo.Migrations.AddBidsTable do
  use Ecto.Migration

  def change do
    create table("bids") do
      add :auction_id, :integer
      add :bid_value, :float
      add :bidder, :string
    end
  end
end
