defmodule ExAuctionsManager.AuctionsProcess do
  @moduledoc """
  Genserver that processes bids
  """

  use GenServer

  require Logger

  def init(auction_id: auction_id) do
    # Rebuilds the state for the given auction
    {:ok, %{auction_id: auction_id, latest_bid: 1}}
  end

  def start_link([auction_id: auction_id] = args) do
    GenServer.start_link(__MODULE__, args, name: get_process_name(auction_id))
  end

  def handle_call({:bid, bid}, _from, %{latest_bid: latest_bid} = state)
      when bid > latest_bid do
    # create bid on the db and, if this does not fail,
    # send the websocket message
    {:reply, {:accepted, bid}, %{state | latest_bid: bid}}
  end

  def handle_call({:bid, bid}, _from, %{latest_bid: latest_bid} = state) do
    Logger.error(
      "the bid (#{bid}) as been rejected because it's below or equals the latest bid (#{
        latest_bid
      })"
    )

    {:reply, {:rejected, bid, latest_bid}, state}
  end

  defp get_process_name(auction_id) do
    # This name should be registered in a distributed registry ?
    :"auction-#{auction_id}"
  end

  # Public API
  def bid(auction_id, value) do
    auction_id
    |> get_process_name()
    |> GenServer.call({:bid, value})
  end
end
