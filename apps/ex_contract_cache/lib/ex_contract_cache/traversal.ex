defmodule ExContractCache.Traversal do
  use GenServer
  require Logger

  alias ExContractCache.NFTFecther

  def init(args) do
    Logger.info("Initializing #{__MODULE__}")
    Process.send_after(get_process_name(), :fetch, 1000)

    {:ok, args}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: get_process_name())
  end

  def handle_info(:fetch, state) do
    result = NFTFecther.fetch()
    Logger.debug("Info fetched: #{inspect(result)}")
    Process.send_after(get_process_name(), :fetch, 1000)
    {:noreply, state}
  end

  defp get_process_name do
    TraversalAgent
  end
end
