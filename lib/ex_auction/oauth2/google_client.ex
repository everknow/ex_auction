defmodule ExAuction.GoogleClient do
  @moduledoc """
  Wraps the boilerplate to verify the Google Oauth2 token
  """
  use Tesla, only: [:get]

  plug(Tesla.Middleware.BaseUrl, "https://oauth2.googleapis.com")
  plug(Tesla.Middleware.JSON)

  def verify(id_token) do
    get("/tokeninfo", body: %{id_token: id_token})
  end
end
