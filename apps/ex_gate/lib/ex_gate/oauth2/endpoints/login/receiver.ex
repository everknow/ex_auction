defmodule ExGate.Login.V1.Receiver do
  @moduledoc """
  Login recevier
  """
  use Plug.Router

  alias ExGate.Login.Handler

  require Logger

  plug(Plug.Logger)

  # to be removed in prod
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/" do
    %{"id_token" => id_token} = conn.params

    case Handler.login(id_token) do
      {:error, code, reason} ->
        json_resp(conn, code, reason)

      {:ok, token, _} ->
        conn
        |> put_resp_header("cache-control", "no-store")
        |> put_resp_header("pragma", "no-cache")
        |> json_resp(200, %{
          "access_token" => token,
          "token_type" => "Bearer",
          # Shouldn't the expire come from the Guardian job ?
          "expires_in" => 3600
          # "refresh_token": ??
        })
    end
  end

  defp json_resp(conn, status \\ 200, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end
end
