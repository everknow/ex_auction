defmodule ExContractCache.SortAgent do
  use GenServer

  alias ExContractCache.MemoryStore

  require Logger

  def init(_) do
    {:ok, %{sort_map: %{}}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: get_process_name())
  end

  def handle_call(:first_update, _from, _state) do
    {:reply, :ok, %{sort_map: generate_sort_map()}}
  end

  def handle_call({:update, hashes}, _from, %{sort_map: sort_map} = state) do
    new_sort_map = update_sort_map(sort_map, hashes)

    {:reply, :ok, %{sort_map: new_sort_map}}
  end

  def handle_call(:get, _from, %{sort_map: sort_map} = state) do
    {:reply, sort_map, state}
  end

  def update(hashes) do
    GenServer.call(get_process_name(), {:update, hashes})
  end

  def get do
    GenServer.call(get_process_name(), :get)
  end

  defp generate_sort_map do
    [_, hashes, _, _] = MemoryStore.get_pages()

    hashes
    |> Enum.uniq()
    |> IO.inspect()
    |> Enum.group_by(fn {_hash, index} -> index end, fn {hash, _index} -> hash end)
  end

  defp update_sort_map(sort_map, new_hashes) do
    {_, result} =
      new_hashes
      |> Enum.uniq()
      |> Enum.map_reduce(sort_map, fn hash, acc ->
        if Enum.member?(Map.values(acc), hash) do
          {nil, acc}
        else
          Logger.info("Adding {#{next_key(acc)}, #{hash}} to map")
          {hash, Map.put(acc, next_key(acc), hash)}
        end
      end)

    result
  end

  def get_process_name do
    SortAgent
  end

  defp next_key(sort_map) do
    sort_map
    |> Map.keys()
    |> Enum.max()
    |> (&(&1 + 1)).()
  rescue
    Enum.EmptyError -> 1
  end
end
