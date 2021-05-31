defmodule ExAuctionsAdmin.BlindAuctionsEndpointTests do
  use ExAuctionsAdmin.RepoCase, async: false

  alias ExAuctionsManager.{Auction, Bid, DB, Repo}

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

      IO.inspect(body)
      # TODO: fix this
    end
  end
end
