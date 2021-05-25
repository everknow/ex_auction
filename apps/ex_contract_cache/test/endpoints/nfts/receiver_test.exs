defmodule ExContractCache.Endpoints.NFT.ReceiverTest do
  use ExUnit.Case, async: false

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
                 "http://localhost:10002/api/v1/nfts",
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

      assert {:ok, %Tesla.Env{status: 200}} =
               Tesla.get(
                 Tesla.client([]),
                 "http://localhost:10002/api/v1/nfts?#{
                   %{"startIndex" => "1", "limit" => 10} |> URI.encode_query()
                 }",
                 headers: [
                   {"authorization", "Bearer #{token}"}
                 ]
               )
    end
  end
end
