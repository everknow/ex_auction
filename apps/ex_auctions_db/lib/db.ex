defmodule ExAuctionsDB.DB do
  @moduledoc """
  This module has the responsibility to define the DB api

  """

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsDB.{Auction, Bid, Repo, User}
  alias ExGate.WebsocketUtils

  @page Application.get_env(:ex_auctions_manager, :page_size, 20)

  require Logger

  @doc """
  Creates an offer for a  blind auction.
  """
  def create_offer(auction_id, bid_value, bidder) do
    create_bid(auction_id, bid_value, bidder, true)
  end

  @doc """
  Creates a bid for a standard auction
  """
  def create_bid(auction_id, bid_value, bidder, blind \\ false) do
    {_, status} =
      Repo.transaction(fn ->
        # This raises and exception that invalidates the transaction, in case
        {:ok, %User{google_id: ^bidder}} = get_user(bidder)

        bid_changeset =
          %Bid{}
          |> Bid.changeset(%{auction_id: auction_id, bid_value: bid_value, bidder: bidder})

        with %Auction{} = auction <-
               get_and_lock_auction(auction_id, blind),
             true <- is_active(auction) do
          process_bid_request(auction, bid_changeset)
        else
          nil ->
            Logger.error("auction #{auction_id} does not exist")
            {:error, add_error(bid_changeset, :auction_id, "auction does not exist")}

          false ->
            {:error, add_error(bid_changeset, :auction_id, "auction is expired")}
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
        {:error, add_error(bid_changeset, :auction_id, "auction is closed")}

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
        {:error, add_error(bid_changeset, :bid_value, "below auction base", value: auction_base)}
    end
  end

  def get_bid_and_outbid(auction_id) do
    from(bid in Bid,
      select: bid,
      order_by: [desc: bid.id],
      limit: 2
    )
    |> Repo.all()
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
        join: auction in Auction,
        on: bid.auction_id == ^auction_id,
        where: auction.blind == false and auction.id == ^auction_id,
        select: count(bid.id)
      )
      |> Repo.one()

    offset = page * size
    last = (page + 1) * size

    q =
      from(bid in Bid,
        join: auction in Auction,
        on: bid.auction_id == ^auction_id,
        where: auction.blind == false and auction.id == ^auction_id,
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
    from(auction in Auction,
      where: auction.blind == false,
      select: auction
    )
    |> Repo.all()
  end

  def get_auction(auction_id) do
    Repo.get(Auction, auction_id)
  end

  def get_and_lock_auction(auction_id, blind \\ false) do
    from(a in Auction, where: a.id == ^auction_id and a.blind == ^blind, lock: "FOR UPDATE")
    |> Repo.one()
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
       add_error(
         bid_changeset,
         :bid_value,
         "below highest bid",
         value: highest_bid
       )}
    end
  end

  @doc """
  Idempotent registration. It fails only if the user tries to register itself again
  with a different couple {email, username}
  """
  def register_user(email, username) do
    case %User{}
         |> User.changeset(%{username: username, google_id: email})
         |> Repo.insert() do
      {:ok, %User{username: ^username, google_id: ^email} = user} ->
        {:ok, user}

      {:error, %Ecto.Changeset{valid?: false} = err} ->
        Logger.error("username already registered")
        {:error, "username already registered"}
    end
  end

  def get_user(google_id) do
    case Repo.get(User, google_id) do
      nil -> {:error, "user not found"}
      %User{google_id: ^google_id} = user -> {:ok, user}
    end
  end

  def get_best_bids do
    q =
      from(b in Bid,
        join: auction in Auction,
        on: b.auction_id == auction.id,
        where: auction.blind == true,
        group_by: [b.auction_id, b.bidder],
        select: {b.auction_id, b.bidder, max(b.bid_value)}
      )

    q |> Repo.all() |> IO.inspect(label: "All results") |> aggregate_query_result()
  end

  def aggregate_query_result([]) do
    %{}
  end

  def aggregate_query_result(data) do
    data
    |> Enum.group_by(fn {auction_id, bidder, bid_value} -> auction_id end)
    |> Enum.reduce([], fn {_key, values_list}, acc ->
      acc ++
        [Enum.max_by(values_list, fn {auction_id, bidder, bid_value} -> bid_value end)]
    end)
    |> Enum.into(%{}, fn {auction_id, bidder, bid_value} ->
      {auction_id, [bidder, bid_value]}
    end)
  end

  def user_has_bid?(bidder, auction_id) do
    q =
      from(bid in Bid,
        join: auction in Auction,
        on: bid.auction_id == auction.id,
        where: bid.bidder == ^bidder,
        select: count(bid.id)
      )

    case Repo.all(q) do
      [0] -> false
      [_] -> true
    end
  end

  def get_best_offer_for_auction(auction_id) do
    q =
      from(bid in Bid,
        join: auction in Auction,
        on: bid.auction_id == auction.id,
        where: auction.id == ^auction_id,
        limit: 1
      )

    Repo.one(q)
  end
end
