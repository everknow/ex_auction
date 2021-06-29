defmodule ExAuctionsDB.Repo.Migrations.AddAuctionIntTimestamp do
  use Ecto.Migration

  alias ExAuctionsDB.{Auction, Repo}

  def up do
    alter table("auctions") do
      add(:expiration_date_int, :integer, null: true)
      add(:creation_date_int, :integer, null: true)
    end
    manipulate()

  end

  def down do
    alter table("auctions") do
      remove :expiration_date_int
      remove :creation_date_int
    end
  end


  def manipulate() do
    Auction
    |> Repo.all()
    |> Enum.map(&convert/1)
  end

  defp convert(auction) do
    {:ok, %Auction{}} = datetime_to_int(auction)
  end

  defp datetime_to_int(
         %Auction{creation_date: creation_date, expiration_date: expiration_date} = auction
       ) do
    creation_date_int = DateTime.to_unix(creation_date) |> IO.inspect(label: "Creation date modified")
    expiration_date_int = DateTime.to_unix(expiration_date) |> IO.inspect(label: "Expiration date modified")

    auction
    |> Auction.changeset(%{
      expiration_date_int: expiration_date_int,
      creation_date_int: creation_date_int
    })
    |> Repo.update()
  end


end
