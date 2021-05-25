defmodule ExContractCache.Traversal do
  use GenServer
  require Logger

  def init(args) do
    Logger.info("Initializing #{__MODULE__}")
    {:ok, args}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: TraversalAgent)
  end

  def fetch do
  end
end
