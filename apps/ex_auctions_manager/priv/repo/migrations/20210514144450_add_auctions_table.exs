defmodule ExAuctionsManager.Repo.Migrations.AddAuctionsTable do
  use Ecto.Migration

  def change do
    create table("auctions") do
      add :open, :boolean
      add :creation_date, :utc_datetime
      add :expiration_date, :utc_datetime
      add :auction_base, :integer, null: false
      add :highest_bid, :integer, null: true
      add :highest_bidder, :string, null: true
    end
  end
end
