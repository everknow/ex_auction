defmodule ExAuction.Login.Handler.Tests do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExAuction.GoogleClient
  alias ExAuction.Login.Handler

  import ExUnit.CaptureLog
  import Mock

  describe "Handler tests" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get, url: "https://oauth2.googleapis.com/tokeninfo"} ->
          %Tesla.Env{status: 200, body: {:ok, "something"}}
      end)

      :ok
    end

    test "/login success" do
      with_mock(GoogleClient,
        verify: fn id_token ->
          {:ok,
           %{
             body:
               %{
                 "email" => "bruno.ripa@gmail.com",
                 "sub" => "some_id",
                 "aud" => Application.fetch_env!(:ex_auction, :google_client_id)
               }
               |> Jason.encode!()
           }}
        end
      ) do
        assert {:ok, _access_token,
                %{
                  "aud" => "ExAuction",
                  "exp" => _,
                  "iat" => _,
                  "iss" => "ExAuction",
                  "jti" => _,
                  "nbf" => _,
                  "sub" => _,
                  "typ" => "access"
                }} = Handler.login("token")
      end
    end

    test "/login failure - unable to decode google payload" do
      with_mock(GoogleClient,
        verify: fn id_token ->
          {:ok,
           %{
             body: "cant_decode_me"
           }}
        end
      ) do
        assert capture_log(fn ->
                 {
                   :error,
                   401,
                   "could not login"
                 } = Handler.login("token")
               end) =~ "unable to decode google response body: \"cant_decode_me\""
      end
    end

    test "/login failure - verify error" do
      with_mock(GoogleClient,
        verify: fn id_token ->
          {:error, "something went wrong"}
        end
      ) do
        assert capture_log(fn ->
                 assert {
                          :error,
                          500,
                          "could not reach google service"
                        } = Handler.login("token")
               end) =~ "unable to verify the google token: \"something went wrong\""
      end
    end
  end
end
