defmodule ExContractCache.Endpoints.NFT.Receiver do
  use Plug.Router

  use Plug.Debugger,
    otp_app: :ex_auctions_manager

  alias ExContractCache.NFTFetcher
  alias ExContractCache.Endpoints.NFT.Handler

  require Logger

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Guardian.Plug.Pipeline,
    module: ExGate.Guardian,
    error_handler: ExGate.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})
  plug(Guardian.Plug.EnsureAuthenticated)

  # to be removed in prod
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/page" do
    try do
      start_index = Map.fetch!(conn.params, "startIndex")
      limit = Map.fetch!(conn.params, "limit")
      owner_address = Map.get(conn.params, "ownerAddress", nil)

      result = Handler.list_nfts(start_index, limit, owner_address)
      json_resp(conn, 200, result)
    rescue
      KeyError ->
        Logger.error("PATH :: missing mandatory fields in the payload")
        json_resp(conn, 400, "BAD REQUEST")
    end
  end

  defp json_resp(conn, status, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end
end
