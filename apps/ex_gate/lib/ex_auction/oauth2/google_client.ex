defmodule ExGate.GoogleClient do
  @moduledoc """
  Wraps the boilerplate to verify the Google Oauth2 token
  """
  use Tesla, only: [:get]

  # https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=

  plug(Tesla.Middleware.BaseUrl, "https://oauth2.googleapis.com")
  plug(Tesla.Middleware.JSON)

  def verify(id_token) do
    case get("/tokeninfo", body: %{id_token: id_token}) do
      {:ok, %Tesla.Env{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end
end

# %Tesla.Env{status: 200, body: body} -> {:ok, body}
# %Tesla.Env{status: _status, body: body} -> {:error, body}
