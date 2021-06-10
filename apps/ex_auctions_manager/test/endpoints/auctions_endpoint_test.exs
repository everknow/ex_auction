defmodule ExAuctionsDB.AuctionsEndpointTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{Auction, DB, User, Bid, Auction, Repo}

  describe "Auction endpoint tests" do
    test "auctions list" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), 5)

      {:ok,
       %{
         id: auction_id,
         expiration_date: ^exp,
         auction_base: 100
       }} = DB.create_auction(exp, 100)

      {:ok,
       %{
         expiration_date: ^exp,
         auction_base: 100,
         blind: true
       }} = DB.create_blind_auction(exp, 100)

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
          "http://localhost:10000/api/v1/auctions",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      exp_str = exp |> DateTime.to_iso8601()

      assert [
               %{
                 "id" => ^auction_id,
                 "auction_base" => 100,
                 "expiration_date" => ^exp_str,
                 "open" => true
               }
             ] = Jason.decode!(body)
    end

    test "create auction" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), 5)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 201, body: body}} =
        Tesla.post(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions",
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

    test "create auction with invalid exp date -- 422 unprocessable entity" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), -5)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 422, body: body}} =
        Tesla.post(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions",
          %{"expiration_date" => exp, "auction_base" => 10}
          |> Jason.encode!(),
          headers: [
            {"authorization", "Bearer #{token}"},
            {"content-type", "application/json"}
          ]
        )

      assert %{
               "reasons" => [
                 "expiry date must be bigger than creation date"
               ]
             } = Jason.decode!(body)
    end

    test "create auction with invalid payload - 400 bad request" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), -5)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 400}} =
        Tesla.post(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions",
          %{"auction_base" => 10}
          |> Jason.encode!(),
          headers: [
            {"authorization", "Bearer #{token}"},
            {"content-type", "application/json"}
          ]
        )

      {:ok, %Tesla.Env{status: 400}} =
        Tesla.post(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions",
          %{"expiration_date" => exp}
          |> Jason.encode!(),
          headers: [
            {"authorization", "Bearer #{token}"},
            {"content-type", "application/json"}
          ]
        )
    end

    test "auction closure endpoint" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), 10)

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
                 "http://localhost:10000/api/v1/auctions",
                 %{"expiration_date" => exp, "auction_base" => 10}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      %{
        "auction_id" => auction_id
      } = body |> Jason.decode!()

      assert {:ok, %Tesla.Env{status: 200}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/auctions/close/#{auction_id}",
                 %{}
                 |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      %{
        id: ^auction_id,
        open: false
      } = DB.get_auction(auction_id)
    end

    test "auction closure endpoint with invalid payload - 400 bad request" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), -5)

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:ok, %Tesla.Env{status: 400}} =
        Tesla.post(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions",
          %{"auction_base" => 10}
          |> Jason.encode!(),
          headers: [
            {"authorization", "Bearer #{token}"},
            {"content-type", "application/json"}
          ]
        )

      {:ok, %Tesla.Env{status: 400}} =
        Tesla.post(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions",
          %{"expiration_date" => exp}
          |> Jason.encode!(),
          headers: [
            {"authorization", "Bearer #{token}"},
            {"content-type", "application/json"}
          ]
        )
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
          "http://localhost:10000/api/v1/auctions/status?auction_id=#{auction_id}&user_id=#{
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
          "http://localhost:10000/api/v1/auctions/status?auction_id=#{auction_id}&user_id=#{
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
          "http://localhost:10000/api/v1/auctions/status?auction_id=#{auction_id}&user_id=i_dont_exist@domain.com",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert body == "3"

      {:ok, %Tesla.Env{status: 200, body: body}} =
        Tesla.get(
          Tesla.client([]),
          "http://localhost:10000/api/v1/auctions/status?auction_id=#{-1}&user_id=#{user_id_1}",
          headers: [
            {"authorization", "Bearer #{token}"}
          ]
        )

      assert body == "3"
    end
  end
end
