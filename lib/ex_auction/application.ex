defmodule ExAuction.Application do
  @moduledoc false

  use Application

  alias ExAuction.{Router, SocketHandler}
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        # This must come from config, so that it can be https on prod
        scheme: :http,
        plug: Router,
        options: [
          port: Application.get_env(:ex_auction, :port, 8080),
          dispatch: dispatch()
        ]
      )
    ]

    opts = [strategy: :one_for_one, name: ExAuction.Application]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", SocketHandler, []},
         {:_, Plug.Adapters.Cowboy2.Handler, {ExAuction.Router, []}}
       ]}
    ]
  end
end
