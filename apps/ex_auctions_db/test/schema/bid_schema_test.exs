defmodule ExAuctionsDB.BidSchemaTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{Auction, Bid, DB, User}

  describe "Schema tests" do
    setup do
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 10)

      {:ok, %Auction{} = auction} = DB.create_auction(expiration_date, 10)
      {:ok, %User{} = user} = DB.register_user("email@domain.com", "bid_username")
      {:ok, %{auction: auction, user: user}}
    end

    test "bid creation success", %{
      auction: %Auction{id: auction_id},
      user: %User{google_id: user_id}
    } do
      {:ok, %User{google_id: user_2_id}} = DB.register_user("email2@domain.com", "bidder_2")

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 10,
                bidder: ^user_id
              }} = DB.create_bid(auction_id, 10, user_id)

      %Auction{id: ^auction_id, highest_bidder: ^user_id, highest_bid: 10} =
        Auction |> Repo.get(auction_id)

      assert {
               :error,
               %Ecto.Changeset{valid?: false} = cs
             } = DB.create_bid(auction_id, 10, user_2_id)

      assert [bid_value: {"below highest bid", [value: 10]}] = cs.errors

      %Auction{id: ^auction_id, highest_bidder: user_id, highest_bid: 10} =
        Auction |> Repo.get(auction_id)
    end

    test "bid creation failure - non existing auction", %{user: %User{google_id: user_id}} do
      assert {:error, %Ecto.Changeset{valid?: false} = cs} = DB.create_bid(-1, 9, user_id)

      assert "auction does not exist" in errors_on(cs).auction_id
    end

    test "bid creation failure - invalid blind auction", %{user: user} do
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 10)

      {:ok, %Auction{id: blind_auction_id}} = DB.create_blind_auction(expiration_date, 10)

      assert {:error, %Ecto.Changeset{valid?: false} = cs} =
               DB.create_bid(blind_auction_id, 10, user.google_id)

      assert "auction does not exist" in errors_on(cs).auction_id
    end

    test "bid creation failure - bid below auction base", %{
      auction: %Auction{id: auction_id},
      user: user
    } do
      assert {:error, %Ecto.Changeset{valid?: false} = cs} =
               DB.create_bid(auction_id, 1, user.google_id)

      assert [bid_value: {"below auction base", [value: 10]}] = cs.errors
    end

    test "bids list", %{auction: %Auction{id: auction_id}, user: user} do
      for elem <- 1..32 do
        bid_value = elem * 10
        bidder = user.google_id

        {:ok, %Bid{auction_id: ^auction_id, bid_value: ^bid_value, bidder: ^bidder}} =
          DB.create_bid(auction_id, bid_value, bidder)
      end

      assert {_bids, %{next_page: 1}} = DB.list_bids(auction_id, 0, 10)
      assert {_bids, %{prev_page: 0, next_page: 2}} = DB.list_bids(auction_id, 1, 10)

      assert {_bids, %{prev_page: 1, next_page: 3}} = DB.list_bids(auction_id, 2, 10)

      assert {bids, %{prev_page: 2}} = DB.list_bids(auction_id, 3, 10)

      assert length(bids) == 2
      assert {_bids, %{}} = DB.list_bids(auction_id, 4, 10)
    end

    test "bids creation - non_existing auction", %{user: user} do
      assert {:error, %Ecto.Changeset{valid?: false} = cs} = DB.create_bid(1, 10, user.google_id)

      assert "auction does not exist" in errors_on(cs).auction_id
    end
  end

  describe "demo test" do
    setup do
      # 4 seconds for testing purposes
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 0, 0, 10)
      {:ok, %Auction{} = auction} = DB.create_auction(expiration_date, 100)
      {:ok, %User{} = user} = DB.register_user("email@domain.com", "bid_username")
      {:ok, %{auction: auction, user: user}}
    end

    test "scenario 1", %{auction: %Auction{id: auction_id}, user: %User{google_id: user_id}} do
      {:ok, %User{google_id: user_2_id}} = DB.register_user("email2@domain.com", "bidder_name_2")
      assert {:error, cs} = DB.create_bid(auction_id, 90, user_id)
      assert [bid_value: {"below auction base", [value: 100]}] = cs.errors

      assert {:ok, %Bid{bid_value: 120, bidder: ^user_id}} =
               DB.create_bid(auction_id, 120, user_id)

      assert {:error, cs} = DB.create_bid(auction_id, 110, user_2_id)

      assert [bid_value: {"below highest bid", [value: 120]}] = cs.errors

      assert {:ok, %Bid{bid_value: 130, bidder: ^user_2_id}} =
               DB.create_bid(auction_id, 130, user_2_id)
    end
  end
end
