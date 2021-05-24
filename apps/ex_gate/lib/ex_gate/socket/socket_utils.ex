defmodule ExGate.WebsocketUtils do
  require Logger

  def get_auction_pg_name(auction_id) do
    "AUCTION::" <> to_string(auction_id)
  end

  def get_blind_bidder_pg_name(user_id) do
    "BLIND::BIDDER::" <> to_string(user_id)
  end

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

  def notify_blind_bid_success(auction_id, bidder) do
    name =
      bidder
      |> get_blind_bidder_pg_name()

    :pg2.create(name)

    name
    |> IO.inspect(label: "Lookup:")
    |> :pg2.get_local_members()
    |> Enum.each(fn pid ->
      Logger.debug("Notifying blind bid success for #{bidder} to #{inspect(pid)}")

      send(
        pid,
        %{notification_type: :blind_bid_success, auction_id: auction_id}
        |> Jason.encode!()
      )
    end)
  end

  def notify_outbid(auction_id, bidder) do
    name =
      bidder
      |> get_blind_bidder_pg_name()

    :pg2.create(name)

    name
    |> IO.inspect(label: "Lookup:")
    |> :pg2.get_local_members()
    |> Enum.each(fn pid ->
      Logger.debug("Notifying outbid for #{bidder} to #{inspect(pid)}")

      send(
        pid,
        %{notification_type: :outbid, auction_id: auction_id}
        |> Jason.encode!()
      )
    end)
  end

  def notify_blind_bid_rejection(auction_id, bidder) do
    name =
      bidder
      |> get_blind_bidder_pg_name()

    :pg2.create(name)

    name
    |> IO.inspect(label: "Lookup:")
    |> :pg2.get_local_members()
    |> Enum.each(fn pid ->
      Logger.debug("Notifying blind bid rejection for #{bidder} to #{inspect(pid)}")

      send(
        pid,
        %{notification_type: :blind_bid_rejection, auction_id: auction_id}
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

  def register_user_identity(user_id, pid) do
    name = user_id |> get_blind_bidder_pg_name() |> IO.inspect(label: "**********")

    :pg2.create(name)

    :pg2.join(name, pid)
  end
end
