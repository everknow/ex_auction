defmodule ExAuctionsManager.AuctionsProcess do
  @moduledoc """
  Genserver that processes bids
  """

  use GenServer
  alias ExAuctionsManager.DB
  require Logger

  def init(auction_id: auction_id) do
    # Rebuilds the state for the given auction
    {:ok, %{auction_id: auction_id, latest_bid: DB.get_latest_bid(auction_id)}}
  end

  def start_link([auction_id: auction_id] = args) do
    GenServer.start_link(__MODULE__, args, name: get_process_name(auction_id))
  end

  def handle_call(
        {:bid, bid_value, bidder},
        _from,
        %{latest_bid: latest_bid, auction_id: auction_id} = state
      )
      when bid_value > latest_bid do
    # create bid on the db and, if this does not fail,
    # send the websocket message
    case DB.create_bid(auction_id, bid_value, bidder) do
      {:ok, _} ->
        {:reply, {:accepted, bid_value}, %{state | latest_bid: bid_value}}

      {:error, %Ecto.Changeset{valid?: false}} ->
        Logger.error("unable to bid #{bid_value} on auction #{auction_id} for user #{bidder}")
        {:reply, {:rejected, bid_value, latest_bid}, state}
    end
  end

  def handle_call({:bid, bid_value, bidder}, _from, %{latest_bid: latest_bid} = state) do
    Logger.error(
      "the bid (#{bid_value}) as been rejected because it's below or equals the latest bid (#{
        latest_bid
      })"
    )

    {:reply, {:rejected, bid_value, latest_bid}, state}
  end

  defp get_process_name(auction_id) do
    # This name should be registered in a distributed registry ?
    :"auction-#{auction_id}"
  end

  # Public API
  def bid(auction_id, bid_value, bidder) do
    auction_id
    |> get_process_name()
    |> GenServer.call({:bid, bid_value, bidder})
  end

  def ready?(auction_id) do
    auction_id
    |> get_process_name()
    |> Process.whereis()
    |> Process.alive?()
  end

  def spawn(auction_id) do
    {:ok, _pid} = __MODULE__.start_link(auction_id: auction_id)
    :started
  end
end
