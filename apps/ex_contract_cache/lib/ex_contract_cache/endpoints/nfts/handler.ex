defmodule ExContractCache.Endpoints.NFT.Handler do
  # TODO: This  must be in the config

  @base_uri "https://everknow.it/web3"
  @contract "0xe04DCd6e51312E05b43466463687425Da3229cde"
  @headers [{"Accept", "application/json"}]

  def list_nfts(start_index, limit, owner_address) do
    {:ok, %{body: body} = response} =
      Tesla.post(
        @base_uri <> "/read/" <> @contract,
        %{
          name: "getPage",
          args: [%{t: "uint256", v: "1"}, %{t: "uint8", v: "30"}],
          t: %{ts: ["address[]", "bytes32[]", "uint256[]", "uint256"]}
        }
        |> Jason.encode!(),
        @headers
      )

    %{"ok" => [addresses, hashes, prices, last] = info} = Jason.decode!(body)

    # Counting editions
    {_, editions} =
      Enum.map_reduce(hashes, %{}, fn elem, acc ->
        {1, Map.update(acc, elem, 1, fn v -> v + 1 end)}
      end)

    {_, sales} =
      Enum.zip([hashes, prices])
      |> Enum.map_reduce(%{}, fn {hash, price} = t, acc ->
        case price do
          "0" -> {0, acc}
          _ -> {1, Map.update(acc, hash, 1, fn v -> v + 1 end)}
        end
      end)

    hashes
    |> Enum.uniq()
    |> Enum.map(fn hash ->
      %{
        hash: hash,
        availableEditions: Map.fetch!(sales, hash),
        totalEditions: Map.fetch!(editions, hash)
      }
    end)
  end
end
