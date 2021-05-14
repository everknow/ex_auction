defmodule ExAuctionsManager.DB do
  @moduledoc """
  This module has the responsibility to define the DB api

  """

  import Ecto.Query

  alias ExAuctionsManager.{Bid, Repo}
  @page Application.compile_env(:ex_auctions_manager, :page_size, 20)

  @doc """
  Bid function.

  Input:

    - auction_id: the id of the auction
    - bid_value: the bid value
  """
  def create_bid(auction_id, bid_value, bidder) do
    %Bid{}
    |> Bid.changeset(%{auction_id: auction_id, bid_value: bid_value, bidder: bidder})
    |> Repo.insert()
  end

  @doc """
  List auctions function.

  Input:

    - auction_id: the id of the auction
    - page (optional): page number
    - size (optional): number of bids per page
  """
  def list_bids(auction_id, page \\ 0, size \\ @page) when is_bitstring(auction_id) do
    q = from(bid in Bid, where: bid.auction_id == ^auction_id)
    Repo.all(q)
  end
end
