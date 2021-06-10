defmodule ExAuctionsAdmin.BlindAuctionsEndpointTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{Auction, Bid, DB, User, Repo}

  describe "Offer creation endpoint" do
    test "successful creation" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), 5)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 201, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10001/api/v1/blind_auctions",
                 %{"expiration_date" => exp, "auction_base" => 10}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert Repo.all(Auction) |> length() == 1

      assert [
               %Auction{
                 id: auction_id,
                 auction_base: 10
               }
             ] = Repo.all(Auction)

      assert %{
               "auction_id" => ^auction_id,
               "auction_base" => 10
             } = Jason.decode!(body)
    end

    test "creation failure" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), -1)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 422, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10001/api/v1/blind_auctions",
                 %{"expiration_date" => exp, "auction_base" => 10}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert %{"reasons" => ["expiry date must be bigger than creation date"]} =
               Jason.decode!(body)
    end
  end

  describe "Auction status endpoint tests" do
    test "/status" do
      {:ok, %User{google_id: user_id_1} = user} =
        DB.register_user("email@domain.com", "bid_username")

      {:ok, %User{google_id: user_id_2} = user_2} =
        DB.register_user("email2@domain.com", "bid_username_2")

      exp = TestUtils.shift_datetime(TestUtils.get_now(), 5)

      assert {:ok,
              %Auction{
                id: auction_id,
                expiration_date: ^exp,
                auction_base: 100,
                blind: true
              }} = DB.create_blind_auction(exp, 100)

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 100,
                bidder: ^user_id_1
              }} = DB.create_offer(auction_id, 100, user_id_1)

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 101,
                bidder: ^user_id_2
              }} = DB.create_offer(auction_id, 101, user_id_2)

      assert {:ok,
              %Bid{
                auction_id: ^auction_id,
                bid_value: 102,
                bidder: ^user_id_1
              }} = DB.create_offer(auction_id, 102, user_id_1)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 200, body: body}} =
        Tesla.get(
          Tesla.client([]),
          "http://localhost:10001/api/v1/blind_auctions/status?auction_id=#{auction_id}&user_id=#{
            user_id_1
          }",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert body == "1"

      {:ok, %Tesla.Env{status: 200, body: body}} =
        Tesla.get(
          Tesla.client([]),
          "http://localhost:10001/api/v1/blind_auctions/status?auction_id=#{auction_id}&user_id=#{
            user_id_2
          }",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert body == "2"

      {:ok, %Tesla.Env{status: 200, body: body}} =
        Tesla.get(
          Tesla.client([]),
          "http://localhost:10001/api/v1/blind_auctions/status?auction_id=#{auction_id}&user_id=i_dont_exist@domain.com",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert body == "3"

      {:ok, %Tesla.Env{status: 200, body: body}} =
        Tesla.get(
          Tesla.client([]),
          "http://localhost:10001/api/v1/blind_auctions/status?auction_id=#{-1}&user_id=#{
            user_id_1
          }",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert body == "3"
    end
  end
end
