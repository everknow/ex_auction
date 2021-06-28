defmodule ExAuctionsDB.DBTests do
  use ExAuctionsDB.RepoCase

  alias ExAuctionsDB.{Bid, Auction, User, DB}

  describe "DB" do
    test "user_has_bids?" do
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 10)

      {:ok, %Auction{id: auction_id} = auction} = DB.create_blind_auction(expiration_date, 10)

      {:ok, %User{google_id: user_id_1} = user} =
        DB.register_user("email@domain.com", "bid_username")

      {:ok, %User{google_id: user_id_2} = user_2} =
        DB.register_user("email2@domain.com", "bid_username_2")

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 10,
                bidder: ^user_id_1
              }} = DB.create_offer(auction_id, 10, user_id_1)

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 11,
                bidder: ^user_id_2
              }} = DB.create_offer(auction_id, 11, user_id_2)

      assert DB.user_has_bid?(user_id_1, auction_id)
      assert DB.user_has_bid?(user_id_2, auction_id)
      refute DB.user_has_bid?("i_dont_exist", auction_id)
    end

    test "get_best_offer_for_auction" do
      expiration_date = TestUtils.shift_datetime(TestUtils.get_now(), 10)

      {:ok, %Auction{id: auction_id} = auction} = DB.create_blind_auction(expiration_date, 10)
      {:ok, %Auction{id: auction_2_id} = auction} = DB.create_blind_auction(expiration_date, 10)

      {:ok, %User{google_id: user_id_1} = user} =
        DB.register_user("email@domain.com", "bid_username")

      {:ok, %User{google_id: user_id_2} = user_2} =
        DB.register_user("email2@domain.com", "bid_username_2")

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 10,
                bidder: ^user_id_1
              }} = DB.create_offer(auction_id, 10, user_id_1)

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 11,
                bidder: ^user_id_2
              }} = DB.create_offer(auction_id, 11, user_id_2)

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 12,
                bidder: ^user_id_1
              }} = DB.create_offer(auction_id, 12, user_id_1)

      assert %Bid{bidder: ^user_id_1} = DB.get_best_offer_for_auction(auction_id)

      # Non existing auction
      assert is_nil(DB.get_best_offer_for_auction(3))
      # Auction with no bids
      assert is_nil(DB.get_best_offer_for_auction(auction_2_id))
    end
  end

  describe "wallet linking" do
    test "link wallet to user - success" do
      email = "email@domain.com"
      email_2 = "email_2@domain.com"
      {:ok, %User{google_id: ^email} = user} = DB.register_user(email, "bid_username")
      {:ok, %User{google_id: ^email_2} = user_2} = DB.register_user(email_2, "bid_username_2")

      assert {:ok, %User{google_id: ^email, wallet: "wallet"}} =
               DB.link_wallet_to_user(email, "wallet")
    end

    test "link wallet to user - wallet already used" do
      email = "email@domain.com"
      email_2 = "email_2@domain.com"
      {:ok, %User{google_id: ^email} = user} = DB.register_user(email, "bid_username")
      {:ok, %User{google_id: ^email_2} = user_2} = DB.register_user(email_2, "bid_username_2")

      assert {:ok, %User{google_id: ^email, wallet: "wallet"}} =
               DB.link_wallet_to_user(email, "wallet")

      assert {:error, "wallet_already_taken"} = DB.link_wallet_to_user(email_2, "wallet")
    end

    test "link wallet to user - user does not exist" do
      email = "email@domain.com"
      assert {:error, "user_not_found"} = DB.link_wallet_to_user(email, "wallet")
    end
  end
end
