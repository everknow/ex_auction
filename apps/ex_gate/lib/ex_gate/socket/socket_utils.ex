defmodule ExGate.WebsocketUtils do
  def get_auction_pg_name(auction_id) do
    "AUCTION::" <> to_string(auction_id)
  end

  def notify_bid(auction_id) do
    name =
      auction_id
      |> get_auction_pg_name()

    :pg2.create(name)

    name
    |> :pg2.get_local_members()
    |> Enum.each(fn pid ->
      send(
        pid,
        %{notification_type: :bid, auction_id: auction_id}
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
