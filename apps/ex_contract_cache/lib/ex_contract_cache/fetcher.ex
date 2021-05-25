defmodule ExContractCache.NFTFecther do
  # TODO: This  must be in the config
  require Logger
  @base_uri "https://everknow.it/web3"
  @contract "0xe04DCd6e51312E05b43466463687425Da3229cde"
  @headers [{"Accept", "application/json"}]

  def fetch do
    [addresses, hashes, prices, last] = do_fetch(1, 10)

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

  def do_fetch(token_id, size) when is_integer(token_id) and is_integer(size) do
    Logger.info("do_fetch :: #{token_id} - #{size}")

    {:ok, %{body: body} = response} =
      Tesla.post(
        @base_uri <> "/read/" <> @contract,
        %{
          name: "getPage",
          args: [
            %{t: "uint256", v: token_id |> to_string()},
            %{t: "uint8", v: size |> to_string()}
          ],
          t: %{ts: ["address[]", "bytes32[]", "uint256[]", "uint256"]}
        }
        |> Jason.encode!(),
        @headers
      )

    %{"ok" => [addresses, hashes, prices, last] = info} = Jason.decode!(body)
    int_last = String.to_integer(last)

    latest = token_id + size

    case latest < int_last do
      true ->
        diff = max(size, latest - token_id)
        [new_addresses, new_hashes, new_prices, last] = do_fetch(latest, diff)

        [addresses ++ new_addresses, hashes ++ new_hashes, prices ++ new_prices, last]

      false ->
        info
    end
  end
end
