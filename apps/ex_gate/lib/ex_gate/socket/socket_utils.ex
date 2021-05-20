defmodule ExGate.WebsocketUtils do
  require Logger

  def get_auction_pg_name(auction_id) do
    "AUCTION::" <> to_string(auction_id)
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

  def register_subscription(auction_id, pid) do
    name =
      auction_id
      |> get_auction_pg_name()

    :pg2.create(name)

    :pg2.join(name, self())
  end
end
