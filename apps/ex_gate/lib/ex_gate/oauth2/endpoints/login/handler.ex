defmodule ExGate.Login.Handler do
  @moduledoc """
  Handles the /login endpoint logic
  """
  alias ExGate.GoogleClient
  alias ExAuctionsDB.{DB, User}
  require Logger

  @google_client_id Application.compile_env!(:ex_gate, :google_client_id)

  def init, do: :ok

  def login(id_token) do
    id_token
    |> verify_google_id_token()
    |> maybe_generate_token()
  end

  @spec verify_google_id_token(String.t()) :: {:ok, String.t()} | {:error, any()}
  defp verify_google_id_token(id_token) do
    case GoogleClient.verify_and_decode(id_token) do
      {:ok, claims} ->
        {:ok, claims}

      {:error, reason} ->
        Logger.error("unable to verify google token")
        {:error, reason}
    end
  end

  defp maybe_generate_token({:error, reason}) do
    {:error, 401, "unable to verify google token"}
  end

  defp maybe_generate_token({:ok, %{"aud" => @google_client_id, "email" => email}}) do
    case DB.get_user(email) do
      {:ok, %User{username: username}} ->
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: username},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      _nope ->
        Logger.error("user does not exist")
        {:error, 404, "user does not exist"}
    end
  end
end
