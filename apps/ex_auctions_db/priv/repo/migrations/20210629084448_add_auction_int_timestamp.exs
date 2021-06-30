defmodule ExAuctionsDB.Repo.Migrations.AddAuctionIntTimestamp do
  use Ecto.Migration

  alias ExAuctionsDB.{Auction, Repo}

  def up do
    alter table("auctions") do
      add(:expiration_date_int, :integer, null: true)
      add(:creation_date_int, :integer, null: true)
    end
  end

  def down do
    alter table("auctions") do
      remove(:expiration_date_int)
      remove(:creation_date_int)
    end
  end
end
