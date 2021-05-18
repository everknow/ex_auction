defmodule ExAuctionsManager.DB do
  @moduledoc """
  This module has the responsibility to define the DB api

  """

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsManager.{Auction, Bid, Repo}
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

        case get_and_lock_auction(auction_id) do
          # Auction does not exist
          nil ->
            Logger.error("auction #{auction_id} does not exist")
            {:error, reject_bid(bid_changeset, :auction_id, "does not exist")}

          # Auction is closed
          %Auction{id: ^auction_id, open: false} ->
            {:error, reject_bid(bid_changeset, :auction_id, "is closed")}

          %Auction{
            auction_base: auction_base,
            open: true
          } = auction
          when auction_base <= bid_value ->
            bigger_than_auction_base(auction, bid_changeset)

          %Auction{
            auction_base: auction_base,
            open: true
          } = auction
          when auction_base > bid_value ->
            {:error, reject_bid(bid_changeset, :bid_value, "below auction base #{auction_base}")}
        end
      end)

    status
  end

  @doc """
  List auctions function.

  Input:

    - auction_id: the id of the auction
    - page (optional): page number
    - size (optional): number of bids per page
  """
  def list_bids(auction_id, page \\ 0, size \\ @page) do
    q = from(bid in Bid, where: bid.auction_id == ^auction_id)
    Repo.all(q)
  end

  def create_auction(expiration_date, auction_base) do
    %Auction{}
    |> Auction.changeset(%{auction_base: auction_base, expiration_date: expiration_date})
    |> Repo.insert()
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

  def get_and_lock_auction(auction_id) do
    from(a in Auction, where: a.id == ^auction_id, lock: "FOR UPDATE")
    |> Repo.one()
  end

  defp reject_bid(bid_changeset, key, reason) do
    bid_changeset
    |> add_error(key, reason)
  end

  defp bigger_than_auction_base(
         %Auction{id: auction_id, highest_bid: nil},
         bid_changeset
       ) do
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

      {:error,
       reject_bid(
         bid_changeset,
         :bid_value,
         "bid value #{bid_value} is not bigger than highest bid #{highest_bid}"
       )}
    end
  end
end
