defmodule ExContractCache.TraverseAndAggregate do
  use GenServer
  require Logger

  alias ExContractCache.NFTFecther

  @memorystore_adapter Application.get_env(:ex_contract_cache, :memorystore_adapter)

  # TODO: this comes from the config
  @size 10
  @time 5000

  def init(_) do
    Process.send_after(get_process_name(), :fetch, 1000)
    {:ok, %{partial_aggregate: [], index: 1}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: get_process_name())
  end

  def handle_info(:fetch, %{partial_aggregate: partial_aggregate, index: index}) do
    page = NFTFecther.fetch(index, @size)

    last_index =
      store(index, page)
      |> IO.inspect(label: "++++ Store(#{index} returns")

    Logger.debug("Check: #{last_index}:#{index + 10}")

    if last_index == index + 10 do
      send(self(), :fetch)
    else
      Logger.debug("Cycle done. Repeting in 5 seconds")
      Process.send_after(self(), :fetch, @time)
    end

    aggregated = aggregate(partial_aggregate, page)
    {:noreply, %{partial_aggregate: aggregated, index: last_index}}
  end

  defp store(index, [addresses, hashes, prices, last_id]) do
    [cached_addresses, cached_hashes, cached_prices, cached_last_id] =
      cached_page = @memorystore_adapter.get("pages")

    # Need to zip since I need the full row to write in redis (address, hash, price)
    {last_index, new_pages} =
      Enum.zip([addresses, hashes, prices])
      # Reduce all the valid rows into the updated cache pages
      |> Enum.filter(fn {_, hash, _} -> hash != String.duplicate("0", 64) end)
      |> Enum.reduce({index, cached_page}, fn {address, hash, price},
                                              {id, [as, ha, pr, l_id] = acc} ->
        {
          increment(id),
          [
            as ++ [address],
            ha ++ [hash],
            pr ++ [price],
            l_id
          ]
        }
      end)

    :ok = @memorystore_adapter.store(new_pages)

    last_index
  end

  def aggregate([], page) do
    calculate_aggregate(page)
  end

  def aggregate(partial_aggregate, page) do
    aggregated_data = calculate_aggregate(page)

    (aggregated_data ++ partial_aggregate)
    |> Enum.group_by(& &1.hash)
    |> Map.values()
    |> Enum.map(fn entries ->
      entries
      |> Enum.reduce(fn entry,
                        %{
                          hash: hash,
                          availableEditions: accumulated_available_editions,
                          totalEditions: accumulated_total_editions
                        } = acc ->
        %{
          hash: hash,
          availableEditions: availableEditions,
          totalEditions: totalEditions
        } = entry

        %{
          hash: hash,
          availableEditions: accumulated_available_editions + availableEditions,
          totalEditions: accumulated_total_editions + totalEditions
        }
      end)
    end)
  end

  def calculate_aggregate([addresses, hashes, prices, _last_id]) do
    # Count editions
    {_, editions} =
      Enum.map_reduce(hashes, %{}, fn elem, acc ->
        {1, Map.update(acc, elem, 1, fn v -> v + 1 end)}
      end)

    # Count items that are for sale
    {_, sales} =
      Enum.zip([hashes, prices])
      |> Enum.map_reduce(%{}, fn {hash, price} = t, acc ->
        case price do
          "0" -> {0, acc}
          _ -> {1, Map.update(acc, hash, 1, fn v -> v + 1 end)}
        end
      end)

    # Aggregate page info
    aggregated_data =
      hashes
      |> Enum.filter(fn elem ->
        elem != "0000000000000000000000000000000000000000000000000000000000000000"
      end)
      |> Enum.uniq()
      |> Enum.map(fn hash ->
        %{
          hash: hash,
          availableEditions: Map.fetch!(sales, hash),
          totalEditions: Map.fetch!(editions, hash)
        }
      end)
  end

  defp get_process_name do
    TraversalAgent
  end

  defp increment(value) when is_bitstring(value) do
    value
    |> String.to_integer()
    |> (&(&1 + 1)).()
    |> to_string()
  end

  defp increment(value) do
    value + 1
  end
end
