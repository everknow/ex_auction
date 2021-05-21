defmodule ExGate.GoogleClient do
  @moduledoc """
  Wraps the boilerplate to verify the Google Oauth2 token
  """

  require Logger

  def verify_and_decode(id_token) do
    case Tesla.get("https://oauth2.googleapis.com/tokeninfo?id_token=#{id_token}") do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        claims =
          %{
            # "alg" => _,
            # "at_hash" => _,
            # "aud" => _,
            # "azp" => _,
            "email" => _,
            # "email_verified" => _,
            # "exp" => _,
            # "family_name" => _,
            # "given_name" => _,
            # "hd" => _,
            # "iat" => _,
            # "iss" => _,
            # "jti" => _,
            # "kid" => _,
            # "locale" => _,
            "name" => _,
            "picture" => _,
            # "sub" => _,
            # "typ" => _
          } = Jason.decode!(body)

        {:ok, claims}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
