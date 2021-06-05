defmodule ExAuctionsDB.AuctionSchemaTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{Auction, DB}
  import ExUnit.CaptureLog

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

      assert {:error,
              %Ecto.Changeset{
                valid?: false,
                changes: %{
                  creation_date: _,
                  auction_base: 10,
                  expiration_date: ^auction_end,
                  open: true
                }
              } = cs} = DB.create_auction(auction_end, 10)

      assert "expiry date must be bigger than creation date" in errors_on(cs).expiration_date
    end

    test "auction creation error - auction is expired" do
      auction_end = TestUtils.shift_datetime(TestUtils.get_now(), 0, 0, 0, 1)

      assert {:ok, %Auction{id: auction_id}} = DB.create_auction(auction_end, 100)
      :timer.sleep(2000)

      assert capture_log(fn ->
               assert {
                        :error,
                        %Ecto.Changeset{valid?: false} = cs
                      } = DB.create_bid(auction_id, 101, "some_bidder")

               assert "auction is expired" in errors_on(cs).auction_id
             end) =~ "auction is expired"
    end
  end
end
