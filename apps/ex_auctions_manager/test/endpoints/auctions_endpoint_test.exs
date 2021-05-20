defmodule ExAuctionsManager.AuctionsEndpointTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB, Repo}

  describe "Auction creation endpoint test" do
    test "/ get auctions list" do
      exp = TestUtils.shift_datetime(TestUtils.get_now(), 5)

      {:ok,
       %{
         id: auction_id,
         expiration_date: ^exp,
         auction_base: 100
       }} = DB.create_auction(exp, 100)

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

    test "/post create auction" do
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

      str_exp = exp |> to_string()
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

    test "/post create auction with invalid exp date" do
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
  end
end
