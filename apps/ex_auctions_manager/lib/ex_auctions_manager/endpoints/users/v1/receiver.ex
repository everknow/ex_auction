defmodule ExAuctionsManager.Users.V1.Receiver do
  @moduledoc """
  Users receiver
  """
  use Plug.Router
  import Plug.Conn

  alias ExAuctionsDB.{DB, User}
  require Logger

  plug(Plug.RequestId)

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

  post "/:email/wallet/:wallet" do
    case valid_payload?(conn) do
      true ->
        %{"email" => email, "wallet" => wallet} = conn.params

        case DB.link_wallet_to_user(email, wallet) do
          {:ok, %User{wallet: ^wallet}} ->
            json_resp(conn, 200, "OK")

          {:error, err} ->
            Logger.error("unable to link wallet #{wallet} to user #{email}")
            json_resp(conn, 422, "unable to execute")
        end

      false ->
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

  defp valid_payload?(conn) do
    Map.has_key?(conn.params, "email") &&
      Map.has_key?(conn.params, "wallet")
  end

  defp format_error_messages(errors) do
    errors |> Enum.map(fn {key, {reason, _}} -> {key, reason} end) |> Enum.into(%{})
  end
end
