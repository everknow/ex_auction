defmodule ExAuctionsDB.Repo.Migrations.AddWalletColumn do
  use Ecto.Migration

  def up do
    alter table("user") do
      add(:wallet, :string, null: true)
    end

    # Can't create index because field can be null
    # create unique_index("user", [:wallet], name: :unique_wallet)
  end

  def down do
    alter table("user") do
      drop(:wallet)
    end

    # drop index("user", ["wallet"])
  end
end
