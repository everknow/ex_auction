defmodule ExAuctionsDB.Repo.Migrations.AddBlidColumn do
  use Ecto.Migration

  def change do
    alter table "auctions" do
      add :blind, :boolean, default: false
    end
  end
end
