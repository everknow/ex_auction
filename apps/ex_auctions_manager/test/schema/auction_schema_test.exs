defmodule ExAuctionsManager.AuctionSchemaTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, DB}

  describe "Auction schema tests" do
    test "auction creation success" do
      assert {:ok,
              %Auction{
                open: true,
                auction_base: 10.0,
                duration: 80000
              }} = DB.create_auction(10.0, 80000)
    end

    test "changeset overriding created and open fields" do
      created = "2018-05-17T17:04:42Z" |> DateTime.from_iso8601()

      attrs = %{
        open: false,
        auction_base: 10.0,
        created: created,
        duration: 80000
      }

      assert %Ecto.Changeset{
               valid?: true,
               changes: %{
                 created: _,
                 auction_base: 10.0,
                 duration: 80000,
                 open: true
               }
             } = Auction.changeset(%Auction{}, attrs)
    end

    test "auction creation error - non positive duration" do
      assert {:error, %Ecto.Changeset{} = error} = DB.create_auction(10.0, -1)
      assert "duration cannot be non-positive" in errors_on(error).duration
    end
  end
end
