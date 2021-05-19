defmodule ExAuctionsManager.AuctionSchemaTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, DB}

  describe "Auction schema tests" do
    test "auction creation success" do
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 2)

      assert {:ok,
              %Auction{
                open: true,
                auction_base: 10,
                expiration_date: ^expiration_date
              }} = DB.create_auction(expiration_date, 10)
    end

    test "changeset overriding created and open fields" do
      created = "2018-05-17T17:04:42Z" |> DateTime.from_iso8601()
      start = TestUtils.shift_datetime(TestUtils.get_now(), -2)
      auction_end = TestUtils.shift_datetime(TestUtils.get_now(), 2)

      attrs = %{
        open: false,
        auction_base: 10,
        creation_date: start,
        expiration_date: auction_end
      }

      assert %Ecto.Changeset{
               valid?: true,
               changes: %{
                 creation_date: _,
                 auction_base: 10,
                 expiration_date: ^auction_end,
                 open: true
               }
             } = Auction.changeset(%Auction{}, attrs)
    end

    test "auction creation error - expiration_date in the past" do
      auction_end = TestUtils.shift_datetime(TestUtils.get_now(), -2)

      attrs = %{
        open: false,
        auction_base: 10,
        expiration_date: auction_end
      }

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{
                 creation_date: _,
                 auction_base: 10,
                 expiration_date: ^auction_end,
                 open: true
               }
             } = cs = Auction.changeset(%Auction{}, attrs)

      assert "expiry date must be bigger than creation date" in errors_on(cs).expiration_date

      {:error, %Ecto.Changeset{valid?: false}} = DB.create_auction(auction_end, 10)
    end
  end
end
