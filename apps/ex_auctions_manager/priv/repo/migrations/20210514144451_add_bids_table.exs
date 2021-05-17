defmodule ExAuctionsManager.Repo.Migrations.AddBidsTable do
  use Ecto.Migration

  def change do
    create table("bids") do
      add :auction_id,    :string
      add :bid_value, :string
      add :bidder, :string
    end
  end
end
