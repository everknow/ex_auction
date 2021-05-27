defmodule ExContractCache.Endpoints.NFT.ReceiverTest do
  use ExUnit.Case, async: false

  alias ExContractCache.TraverseAndAggregate
  import Mock

  describe "/api/v1/nfts" do
    test "400 bad request" do
      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 400}} =
               Tesla.get(
                 Tesla.client([]),
                 "http://localhost:10002/api/v1/nfts/page",
                 headers: [
                   {"authorization", "Bearer #{token}"}
                 ]
               )
    end

    test "200" do
      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      with_mock TraverseAndAggregate,
        get_nfts: fn ->
          [
            %{
              "availableEditions" => 7,
              "hash" => "1",
              "totalEditions" => 7
            },
            %{
              "availableEditions" => 6,
              "hash" => "2",
              "totalEditions" => 9
            },
            %{
              "availableEditions" => 2,
              "hash" => "3",
              "totalEditions" => 10
            }
          ]
        end do
        assert {:ok, %Tesla.Env{status: 200, body: body}} =
                 Tesla.get(
                   Tesla.client([]),
                   "http://localhost:10002/api/v1/nfts/page?#{
                     %{"startIndex" => "1", "limit" => 10} |> URI.encode_query()
                   }",
                   headers: [
                     {"authorization", "Bearer #{token}"}
                   ]
                 )

        assert [
                 %{
                   "availableEditions" => 7,
                   "hash" => "1",
                   "totalEditions" => 7
                 },
                 %{
                   "availableEditions" => 6,
                   "hash" => "2",
                   "totalEditions" => 9
                 },
                 %{
                   "availableEditions" => 2,
                   "hash" => "3",
                   "totalEditions" => 10
                 }
               ] = body |> Jason.decode!()
      end
    end
  end
end
