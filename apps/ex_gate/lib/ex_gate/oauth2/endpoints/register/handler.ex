defmodule ExGate.Register.Handler do
  @moduledoc """
  Handles the /login endpoint logic
  """
  alias ExGate.GoogleClient
  alias ExAuctionsDB.{DB, User}
  require Logger

  def init, do: :ok

  def ping, do: "pong"
  def ping(_context), do: "pong"

  def register(id_token, username) do
    Logger.error("Full login")

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

      {:error, "unable to create user" = reason} ->
        {:error, reason}
    end
  end

  defp maybe_generate_token({:error, reason}) do
    case reason do
      "user does not exist" = user_error ->
        {:error, 404, user_error}

      "email already used for another user" = username_error ->
        {:error, 400, username_error}

      _ ->
        {:error, 401, "cannot verify google id token"}
    end
  end

  defp maybe_generate_token({:ok, %{"aud" => aud}, %User{} = user}) do
    google_client_id = Application.get_env(:ex_gate, :google_client_id)

    case aud do
      ^google_client_id ->
        # create user here? [username | _] = String.split(email, "@")

        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: user.username},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      _nope ->
        Logger.error("`aud` claim not recognized: #{aud}")
        {:error, 401, "could not login"}
    end
  end
end
