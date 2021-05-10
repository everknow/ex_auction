defmodule Gate.Application do

  use Application


  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    Gate.Login.Handler.init()
    Gate.Protected.Handler.init()

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http, # :https
        plug: Gate.Router,
        port: Application.get_env(:gate, :port, 8080)
      )
    ]

    opts = [strategy: :one_for_one, name: Gate.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
