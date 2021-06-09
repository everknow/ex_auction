defmodule ExGate.Register.Handler do
  @moduledoc """
  Handles the /login endpoint logic
  """
  alias ExGate.GoogleClient
  alias ExAuctionsDB.{DB, User}
  require Logger

  def init, do: :ok

  def register(id_token, username) do
    id_token
    |> verify_google_id_token()
    |> maybe_register_user(username)
    |> maybe_generate_token()
  end

  @spec verify_google_id_token(String.t()) :: {:ok, String.t()} | {:error, any()}
  defp verify_google_id_token(id_token) do
    case GoogleClient.verify_and_decode(id_token) do
      {:ok, claims} ->
        {:ok, claims}

      {:error, reason} ->
        Logger.error("unable to verify the google token: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp maybe_register_user({:error, reason}, _username) do
    {:error, reason}
  end

  defp maybe_register_user({:ok, %{"email" => email} = claims}, username) do
    case DB.register_user(email, username) do
      {:ok, %User{username: ^username} = user} ->
        {:ok, claims, user}

      {:error, "username already registered" = reason} ->
        {:error, reason}
    end
  end

  defp maybe_generate_token({:error, reason}) do
    case reason do
      "username already registered" ->
        {:error, 422, reason}

      other ->
        {:error, 401, reason}
    end
  end

  defp maybe_generate_token({:ok, %{"email" => email}, %User{} = user}) do
    google_client_id = Application.get_env(:ex_gate, :google_client_id)

    ExGate.Guardian.encode_and_sign(
      _resource = %{user_id: user.google_id},
      _claims = %{},
      # GOOGLE EXPIRY: decoded["exp"]
      _opts = [ttl: {3600, :seconds}]
    )
  end
end
