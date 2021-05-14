defmodule ExGate.Login.V1.Receiver do
  @moduledoc """
  Login recevier
  """
  use Plug.Router

  alias ExGate.Login.Handler

  require Logger

  plug(Guardian.Plug.Pipeline,
    module: ExGate.Guardian,
    error_handler: ExGate.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})

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

  # TODO: is this to be exposed here ?
  get("/ping", do: send_resp(conn, 200, Handler.ping()))

  post "/login" do
    %{"google_token" => id_token} = conn.params

    case Handler.login(id_token) do
      {:error, code, description} ->
        Logger.error(
          "unable to login: code: #{inspect(code)} description: #{inspect(description)}"
        )

        json_resp(conn, code, %{error: description})

      {:ok, tok, _} ->
        conn
        |> put_resp_header("cache-control", "no-store")
        |> put_resp_header("pragma", "no-cache")
        |> json_resp(200, %{
          "access_token" => tok,
          "token_type" => "Bearer",
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
