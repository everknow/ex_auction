defmodule ExAuctionTest do
  use ExUnit.Case, async: true

  import Plug.Cowboy

  def init([]) do
    [foo: :bar]
  end

  handler = {:_, [], Plug.Cowboy.Handler, {Plug.CowboyTest, [foo: :bar]}}
  @dispatch [{:_, [], [handler]}]

  test "supports Elixir child specs" do
    spec = {Plug.Cowboy, [scheme: :http, plug: __MODULE__, port: 4040]}

    assert %{
             id: {:ranch_listener_sup, Plug.CowboyTest.HTTP},
             modules: [:ranch_listener_sup],
             restart: :permanent,
             shutdown: :infinity,
             start: {:ranch_listener_sup, :start_link, _},
             type: :supervisor
           } = Supervisor.child_spec(spec, [])

    # For backwards compatibility:
    spec = {Plug.Cowboy, [scheme: :http, plug: __MODULE__, options: [port: 4040]]}

    assert %{
             id: {:ranch_listener_sup, Plug.CowboyTest.HTTP},
             modules: [:ranch_listener_sup],
             restart: :permanent,
             shutdown: :infinity,
             start: {:ranch_listener_sup, :start_link, _},
             type: :supervisor
           } = Supervisor.child_spec(spec, [])

    spec =
      {Plug.Cowboy,
       [scheme: :http, plug: __MODULE__, parent: :key, options: [:inet6, port: 4040]]}

    assert %{
             id: {:ranch_listener_sup, Plug.CowboyTest.HTTP},
             modules: [:ranch_listener_sup],
             restart: :permanent,
             shutdown: :infinity,
             start: {:ranch_listener_sup, :start_link, _},
             type: :supervisor
           } = Supervisor.child_spec(spec, [])
  end
end
