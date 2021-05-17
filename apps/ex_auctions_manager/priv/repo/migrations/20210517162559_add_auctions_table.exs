defmodule ExAuctionsManager.Repo.Migrations.AddAuctionsTable do
  use Ecto.Migration

  def change do
    create table("auctions") do
      add :open, :boolean
      add :created, :utc_datetime
      add :duration, :integer
      add :auction_base, :float, null: false
    end
  end
end
