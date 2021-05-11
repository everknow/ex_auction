defmodule ExAuction.Login.Handler do
  @moduledoc """
  Handles the /login endpoint logic
  """
  alias ExAuction.GoogleClient

  require Logger

  def init(), do: :ok

  def ping(), do: "pong"
  def ping(_context), do: "pong"

  def login(id_token) do
    # https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=

    case GoogleClient.verify(id_token) do
      {:ok, response} ->
        google_client_id = Application.get_env(:ex_auction, :google_client_id)

        case Jason.decode(response.body) do
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
            Logger.error("unable to decode google response body: #{response.body}")
            {:error, 401, "could not login"}
        end

      {:error, reason} ->
        Logger.error("unable to verify the google token: #{inspect(reason)}")
        {:error, 500, "could not reach google service"}
    end
  end
end
