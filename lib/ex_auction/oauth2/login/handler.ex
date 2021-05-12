defmodule ExAuction.Login.Handler do
  @moduledoc """
  Handles the /login endpoint logic
  """
  alias ExAuction.GoogleClient

  require Logger

  def init, do: :ok

  def ping, do: "pong"
  def ping(_context), do: "pong"

  @spec login(String.t()) :: {:ok, String.t(), String.t()} | {:error, integer, any()}
  def login(id_token) do
    id_token
    |> verify_token()
    |> maybe_decode_token()
  end

  @spec verify_token(String.t()) :: {:ok, String.t()} | {:error, any()}
  defp verify_token(id_token) do
    case GoogleClient.verify(id_token) do
      {:ok, %{body: body} = _response} ->
        {:ok, body}

      {:error, reason} ->
        Logger.error("unable to verify the google token: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec maybe_decode_token(
          {:ok, any(), any()}
          | {:error, any}
        ) ::
          {:ok, String.t(), String.t()} | {:error, integer, any()}
  defp maybe_decode_token({:error, _reason}) do
    {:error, 500, "could not reach google service"}
  end

  defp maybe_decode_token({:ok, body}) do
    google_client_id = Application.get_env(:ex_auction, :google_client_id)

    case Jason.decode(body) do
      {:ok, %{"aud" => ^google_client_id}} ->
        # create user here? [username | _] = String.split(email, "@")
        user_id = UUID.uuid4()

        ExAuction.Guardian.encode_and_sign(
          _resource = %{user_id: user_id},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      {:error, %Jason.DecodeError{}} ->
        Logger.error("unable to decode google response body: #{inspect(body)}")
        {:error, 401, "could not login"}
    end
  end
end
