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
          nil ->
            Logger.error("auction #{auction_id} does not exist")
            {:error, reject_bid(bid_changeset, :auction_id, "does not exist")}

          %Auction{id: ^auction_id, highest_bid: highest_bid, open: true}
          when highest_bid < bid_value ->
            {:ok, %Bid{}} =
              bid =
              bid_changeset
              |> Repo.insert()

            {:ok, %Auction{id: ^auction_id, highest_bidder: ^bidder, highest_bid: ^bid_value}} =
              update_auction(auction_id, bid_value, bidder)

            bid

          %Auction{id: ^auction_id, highest_bid: nil, open: true, auction_base: auction_base}
          when bid_value >= auction_base ->
            {:ok, %Bid{}} =
              bid =
              bid_changeset
              |> Repo.insert()

            {:ok, %Auction{id: ^auction_id, highest_bidder: ^bidder, highest_bid: ^bid_value}} =
              update_auction(auction_id, bid_value, bidder)

            bid

          %Auction{id: ^auction_id, highest_bid: nil, open: true, auction_base: auction_base} ->
            Logger.error("bid #{bid_value} is below the auction base #{auction_base}")
            {:error, reject_bid(bid_changeset, :bid_value, "bid is not above auction base")}

          %Auction{id: ^auction_id, highest_bid: highest_bid, open: true}
          when highest_bid >= bid_value ->
            Logger.error("bid #{bid_value} is not above highest bid #{highest_bid}")

            {:error,
             reject_bid(
               bid_changeset,
               :bid_value,
               "bid #{bid_value} is not above highest bid #{highest_bid}"
             )}

          %Auction{id: ^auction_id, highest_bid: highest_bid, open: false} ->
            {:error, reject_bid(bid_changeset, :auction_id, "is closed")}
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

  defp get_latest_bid(auction_id) do
    case from(b in Bid,
           right_join: a in Auction,
           on: a.id == b.auction_id,
           where: a.id == ^auction_id,
           limit: 1,
           order_by: [desc: b.bid_value],
           select: b
         )
         |> Repo.one() do
      %Bid{} = bid -> bid
      nil -> nil
    end
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
end
