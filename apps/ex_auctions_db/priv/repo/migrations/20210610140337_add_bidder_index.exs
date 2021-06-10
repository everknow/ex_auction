defmodule ExAuctionsDB.Repo.Migrations.AddBidderIndex do
  use Ecto.Migration


  def up do
      create index("bids", ["bidder"])
  end

  def down do
    drop index("bids", ["bidder"])
  end

end
