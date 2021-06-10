defmodule ExGate.WebsocketUtils do
  require Logger

  alias ExAuctionsDB.DB

  @env (try do
          Mix.env() |> to_string()
        rescue
          _ -> "prod"
        end)

  def get_auction_pg_name(auction_id) do
    @env <> "::AUCTION::" <> to_string(auction_id)
  end

  def get_user_pg_name(user_id) do
    @env <> "::USER::" <> to_string(user_id)
  end

  def get_blind_bidder_pg_name(user_id, auction_id) do
    @env <> "::USER::AUCTION::#{user_id}::#{auction_id}"
  end

  @doc """
  Generic bid notification. Tells all the subscribed bidders that a new bid has been accepted
  for a given auction
  """
  def notify_bid(auction_id, bid_value) do
    name =
      auction_id
      |> get_auction_pg_name()

    :pg2.create(name)

    name
    |> :pg2.get_local_members()
    |> Enum.each(fn pid ->
      Logger.debug("Notifying to #{inspect(pid)}")

      send(
        pid,
        %{notification_type: :bid, auction_id: auction_id, bid_value: bid_value}
        |> Jason.encode!()
      )
    end)
  end

  @doc """
  Receives the id of an user that bid on an action and the auction id: it
  subscribes the user to notifications (in case of outbids) and
  notifies the highest bidder that he's been outbid.any()

  Note: "notify" is not correct here, since we are _not_ notifying anything yet
  """
  def notify_blind_bid_success(auction_id, bidder) do
    # The mapping user - auction_id
    user_auction = get_blind_bidder_pg_name(bidder, auction_id)
    Logger.warn("Notifying blind success: #{user_auction}")

    :pg2.create(user_auction)

    bidder
    |> get_user_pg_name()
    |> :pg2.create()

    # Registering the user to the blid auctions for auction_id
    bidder
    |> get_user_pg_name()
    |> :pg2.get_local_members()
    # We can't assume there's only 1 pid because the user can have multiple
    # browser tabs open
    |> Enum.each(fn pid ->
      Logger.warn("Registering #{user_auction} with pid #{inspect(pid)}")
      :pg2.join(user_auction, pid)
    end)

    notify_blind_bid_outbid(auction_id)
  end

  defp notify_blind_bid_outbid(auction_id) do
    Logger.warn("Notiying outbid for #{auction_id}")
    # I only take 2 bids the get the winner and the outbid
    with [_first, second] <-
           DB.get_bid_and_outbid(auction_id) do
      name =
        second.bidder
        |> get_blind_bidder_pg_name(auction_id)

      Logger.warn("User outbid: #{name}")
      :pg2.create(name)

      name
      |> :pg2.get_local_members()
      |> Enum.each(fn pid ->
        Logger.debug("Notifying outbid for #{second.bidder} to #{inspect(pid)}")

        send(
          pid,
          %{notification_type: :outbid, auction_id: auction_id}
          |> Jason.encode!()
        )
      end)
    end
  end

  def notify_blind_bid_below_best(auction_id, bidder) do
    notify_blind_bid_rejection(auction_id, bidder, :below_highest_bid)
  end

  # Maybe this is not needed
  defp notify_blind_bid_rejection(auction_id, bidder, reason) do
    name =
      bidder
      |> get_blind_bidder_pg_name(auction_id)

    :pg2.create(name)

    name
    |> :pg2.get_local_members()
    |> Enum.each(fn pid ->
      Logger.debug("Notifying blind bid rejection for #{bidder} to #{inspect(pid)}")

      send(
        pid,
        %{notification_type: reason, auction_id: auction_id}
        |> Jason.encode!()
      )
    end)

    Logger.debug("Notified notify_blind_bid_rejection to user #{bidder} - auction #{auction_id}")
  end

  def register_subscription(auction_id, pid) do
    name =
      auction_id
      |> get_auction_pg_name()

    :pg2.create(name)

    :pg2.join(name, pid)
  end

  @doc """
  This function stores the user in the pg2 group, so that we know how to associate
  him to any notification, if needed. Also, we resubscribe him for blind bids messages
  """
  def register_user_identity(user_id, pid) do
    user_pg_name = user_id |> get_user_pg_name()

    # Register user socket process
    :pg2.create(user_pg_name)
    :pg2.join(user_pg_name, pid)

    bids = DB.get_best_bids() |> IO.inspect(label: "Getting best bids")

    auction_ids =
      bids
      |> Enum.filter(fn {auction_id, [bidder, bid_value]} -> user_id == bidder end)
      |> Enum.each(fn {auction_id, [bidder, bid_value]} ->
        Logger.warn("Resubscribing user #{inspect(user_id)} to auction #{inspect(auction_id)}")
        resubscribe_to_blind_bids_messages(user_id, auction_id)
      end)
  end

  def resubscribe_to_blind_bids_messages(bidder, auction_id) do
    # The mapping user - auction_id
    user_auction = get_blind_bidder_pg_name(bidder, auction_id)

    :pg2.create(user_auction)

    user_pg_name =
      bidder
      |> get_user_pg_name()

    user_pg_name
    |> :pg2.create()

    # Registering the user to the blid auctions for auction_id
    user_pg_name
    |> :pg2.get_local_members()
    |> IO.inspect(label: "Reconnecting clients")
    # We can't assume there's only 1 pid because the user can have multiple
    # browser tabs open
    |> Enum.each(fn pid ->
      Logger.warn("Registering #{user_auction} with pid #{inspect(pid)}")
      :pg2.join(user_auction, pid)
    end)
  end
end
