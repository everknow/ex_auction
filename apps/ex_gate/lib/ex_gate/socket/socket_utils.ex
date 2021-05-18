defmodule ExGate.WebsocketUtils do
  def get_auction_pg_name(auction_id) do
    "AUCTION::" <> to_string(auction_id)
  end

  def notify_listeners(auction_id, message) do
    name =
      auction_id
      |> get_auction_pg_name()
      |> IO.inspect(label: "----create")

    :pg2.create(name)

    name
    |> IO.inspect(label: "----glt")
    |> :pg2.get_local_members()
    |> IO.inspect(label: "----each")
    |> Enum.each(fn pid ->
      send(pid, {:auction, message |> Jason.encode!()})
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
