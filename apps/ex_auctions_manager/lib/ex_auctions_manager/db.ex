defmodule ExAuctionsManager.DB do
  @moduledoc """
  This module has the responsibility to define the DB api

  """

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsManager.{Auction, Bid, Repo}
  alias ExGate.WebsocketUtils
  @page Application.compile_env(:ex_auctions_manager, :page_size, 20)

  require Logger

  @doc """
  Bid function.

  Input:

    - auction_id: the id of the auction
    - bid_value: the bid value
  """
  def create_bid(auction_id, bid_value, bidder) do
    {_, status} =
      Repo.transaction(fn ->
        bid_changeset =
          %Bid{}
          |> Bid.changeset(%{auction_id: auction_id, bid_value: bid_value, bidder: bidder})

        with %Auction{} = auction <- get_and_lock_auction(auction_id),
             true <- is_active(auction) do
          process_bid_request(auction, bid_changeset)
        else
          nil ->
            Logger.error("auction #{auction_id} does not exist")
            {:error, reject_bid(bid_changeset, :auction_id, "auction does not exist")}

          false ->
            {:error, reject_bid(bid_changeset, :auction_id, "auction is expired")}
        end
      end)

    status
  end

  defp is_active(auction) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case Timex.compare(now, auction.expiration_date, :second) do
      -1 ->
        true

      _ ->
        Logger.error("is_active :: auction is expired #{now} - #{auction.expiration_date}")
        false
    end
  end

  defp process_bid_request(%Auction{id: auction_id} = auction, bid_changeset) do
    Logger.warn("process_bid_request")
    bid_value = get_field(bid_changeset, :bid_value)
    bidder = get_field(bid_changeset, :bidder)

    case auction do
      # Auction is closed
      %Auction{id: ^auction_id, open: false} ->
        {:error, reject_bid(bid_changeset, :auction_id, "is closed")}

      # bid is not below auction base
      %Auction{
        auction_base: auction_base,
        open: true
      } = auction
      when auction_base <= bid_value ->
        bigger_than_auction_base(auction, bid_changeset)

      # bid is below auction base
      %Auction{
        auction_base: auction_base,
        open: true
      } ->
        {:error, reject_bid(bid_changeset, :bid_value, "below auction base #{auction_base}")}
    end
  end

  @doc """
  List bids function.

  Input:

    - auction_id: the id of the auction
    - page (optional): page number
    - size (optional): number of bids per page
  """
  def list_bids(auction_id, page \\ 0, size \\ @page) do
    bids_count =
      from(bid in Bid,
        select: count(bid.id)
      )
      |> Repo.one()

    offset = page * size
    last = (page + 1) * size

    q =
      from(bid in Bid,
        where: bid.auction_id == ^auction_id,
        limit: ^size,
        offset: ^offset
      )

    results = Repo.all(q)

    headers = %{}

    headers =
      headers
      |> maybe_add_prev_page(page, bids_count, size)
      |> maybe_add_next_page(results, size, page, bids_count)

    {results, headers}
  end

  defp maybe_add_prev_page(headers, 0, bids_count, size) do
    headers
  end

  defp maybe_add_prev_page(headers, page, bids_count, size) do
    if page * size < bids_count do
      headers = Map.put(headers, :prev_page, page - 1)
    else
      headers
    end
  end

  defp maybe_add_next_page(headers, results, size, page, bids_count) do
    last = (page + 1) * size
    Logger.debug("Maybe add next page")

    if length(results) != size || (length(results) == size and last == bids_count) do
      headers
    else
      Logger.debug("Adding page")
      headers |> Map.put(:next_page, page + 1)
    end
  end

  def create_auction(expiration_date, auction_base, blind \\ false) do
    %Auction{}
    |> Auction.changeset(%{
      auction_base: auction_base,
      expiration_date: expiration_date,
      blind: blind
    })
    |> Repo.insert()
  end

  def create_blind_auction(expiration_date, auction_base) do
    create_auction(expiration_date, auction_base, true)
  end

  def update_auction(auction_id, highest_bid, highest_bidder) do
    Auction
    |> Repo.get(auction_id)
    |> change(
      highest_bidder: highest_bidder,
      highest_bid: highest_bid
    )
    |> Repo.update()
  end

  def close_auction(auction_id) when is_integer(auction_id) do
    Auction
    |> Repo.get(auction_id)
    |> change(open: false)
    |> Repo.update()
  end

  def close_auction(auction_id) when is_bitstring(auction_id) do
    auction_id |> String.to_integer() |> close_auction()
  end

  def list_auctions() do
    Auction |> Repo.all()
  end

  def get_auction(auction_id) do
    Repo.get(Auction, auction_id)
  end

  def get_and_lock_auction(auction_id) do
    from(a in Auction, where: a.id == ^auction_id, lock: "FOR UPDATE")
    |> Repo.one()
  end

  defp reject_bid(bid_changeset, key, reason) do
    bid_changeset
    |> add_error(key, reason)
  end

  defp bigger_than_auction_base(
         %Auction{id: auction_id, highest_bid: nil, expiration_date: expiration_date},
         bid_changeset
       ) do
    now = DateTime.utc_now()

    bid_value = get_field(bid_changeset, :bid_value)
    bidder = get_field(bid_changeset, :bidder)

    {:ok, %Bid{} = bid} =
      bid_changeset
      |> Repo.insert()

    {:ok, %Auction{id: ^auction_id, highest_bidder: ^bidder, highest_bid: ^bid_value}} =
      update_auction(auction_id, bid_value, bidder)

    # last operation in the transaction: no exception so far, so this will be executed

    {:ok, bid}
  end

  defp bigger_than_auction_base(
         %Auction{id: auction_id, highest_bid: highest_bid},
         bid_changeset
       ) do
    bid_value = get_field(bid_changeset, :bid_value)
    bidder = get_field(bid_changeset, :bidder)

    if highest_bid < bid_value do
      {:ok, %Bid{} = bid} =
        bid_changeset
        |> Repo.insert()

      {:ok, %Auction{id: ^auction_id, highest_bidder: ^bidder, highest_bid: ^bid_value}} =
        update_auction(auction_id, bid_value, bidder)

      {:ok, bid}
    else
      Logger.error("bid value #{bid_value} is not bigger than highest bid #{highest_bid}")
      # last operation in the transaction: no exception so far, so this will be executed

      {:error,
       reject_bid(
         bid_changeset,
         :bid_value,
         "bid value #{bid_value} is not bigger than highest bid #{highest_bid}"
       )}
    end
  end
end
