defmodule Gate.Login.Handler do

  def init(), do: :ok

  def ping(), do: "pong"

  def ping(_context), do: "pong"

  def login(id_token) do

    # https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=

    case Tesla.get("https://oauth2.googleapis.com/tokeninfo?id_token=#{id_token}", []) do

      {:ok, response} ->
        google_client_id = System.get_env("GOOGLE_CLIENT_ID")

        case Jason.decode!(response.body) do
          %{"email" => _email, "sub" => _auth_id, "aud" => ^google_client_id} = _decoded ->

            # create user here? [username | _] = String.split(email, "@")
            user_id = UUID.uuid4()

            Gate.Guardian.encode_and_sign(
              _resource = %{user_id: user_id},
              _claims = %{},
              _opts = [ttl: {3600, :seconds}]  # GOOGLE EXPIRY: decoded["exp"]
              )



          _what ->
            {:error, 401, "could not login"}

        end

      _what ->
        {:error, 500, "could not reach google service"}
    end

  end

end
