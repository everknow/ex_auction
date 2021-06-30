defmodule ExAuctionsDB.Repo.Migrations.ManipulateDates do
  use Ecto.Migration

  alias ExAuctionsDB.{Repo, Auction}

  def up do
    transform_to_timestamp()
  end

  def down do
    transform_to_datetime()
  end

  def transform_to_timestamp() do
    Auction
    |> Repo.all()
    |> IO.inspect(label: "----")
    |> Enum.map(&convert_to_timestamp/1)
  end

  def transform_to_datetime() do
    Auction
    |> Repo.all()
    |> Enum.map(&convert_to_unix/1)
  end

  defp convert_to_timestamp(auction) do
    {:ok, %Auction{}} = datetime_to_int(auction)
  end

  defp convert_to_unix(auction) do
    {:ok, %Auction{}} = int_to_datetime(auction)
  end

  defp datetime_to_int(
         %Auction{creation_date: creation_date, expiration_date: expiration_date} = auction
       ) do
    creation_date_int =
      DateTime.to_unix(creation_date) |> IO.inspect(label:   "Creation  date  modified")

    expiration_date_int =
      DateTime.to_unix(expiration_date) |> IO.inspect(label: "Expiration date modified")

    auction
    |> Auction.changeset(%{
      expiration_date_int: expiration_date_int,
      creation_date_int: creation_date_int
    })
    |> Repo.update()
  end

  defp int_to_datetime(
         %Auction{
           creation_date_int: creation_date_int,
           expiration_date_int: expiration_date_int
         } = auction
       ) do

        IO.inspect(auction, label: "Working on")
    creation_date =
      Timex.from_unix(creation_date_int) |> IO.inspect(label: "Creation date reverted")

    expiration_date =
      Timex.from_unix(expiration_date_int) |> IO.inspect(label: "Expiration date reverted")

    auction
    |> Auction.changeset(%{
      expiration_date: expiration_date,
      creation_date: creation_date
    })
    |> Repo.update()
  end
end
