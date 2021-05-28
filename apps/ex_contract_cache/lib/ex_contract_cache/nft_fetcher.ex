defmodule ExContractCache.NFTFetcher do
  # TODO: This  must be in the config

  require Logger

  @base_uri Application.fetch_env!(:ex_contract_cache, :base_uri)
  @contract Application.fetch_env!(:ex_contract_cache, :contract)

  def fetch(index, size) do
    [addresses, hashes, prices, last] = info = make_call(index, size)

    info
  end

  defp do_fetch(token_id, size) when is_integer(token_id) and is_integer(size) do
    [addresses, hashes, prices, last] = info = make_call(token_id, size)
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

  defp make_call(token_id, size) do
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
        [{"content-type", "application/json"}]
      )

    %{"ok" => [_addresses, _hashes, _prices, _last] = result} = Jason.decode!(body)
    result
  end
end
