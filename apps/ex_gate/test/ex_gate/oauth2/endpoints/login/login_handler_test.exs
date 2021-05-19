defmodule ExGate.Login.HandlerTests do
  use ExUnit.Case, async: false
  use Plug.Test

  alias ExGate.GoogleClient
  alias ExGate.Login.Handler

  import ExUnit.CaptureLog
  import Mock

  setup_all do
    Tesla.Mock.mock(fn
      %{method: :get, url: "https://oauth2.googleapis.com/tokeninfo"} ->
        %Tesla.Env{status: 200, body: {:ok, "something"}}
    end)

    :ok
  end

  describe "Handler tests" do
    test "/login success" do
      with_mock(GoogleClient,
        verify_and_decode: fn id_token ->
          {:ok,
           %{
             "aud" => Application.get_env(:ex_gate, :google_client_id)
           }}
        end
      ) do
        assert {:ok, _access_token,
                %{
                  "aud" => "ExGate",
                  "exp" => _,
                  "iat" => _,
                  "iss" => "ExGate",
                  "jti" => _,
                  "nbf" => _,
                  "sub" => _,
                  "typ" => "access"
                }} = Handler.login("token")
      end
    end

    test "/login failure - unable to decode google payload" do
      with_mock(GoogleClient,
        verify_and_decode: fn id_token ->
          {:error, "something failed"}
        end
      ) do
        assert capture_log(fn ->
                 assert {
                          :error,
                          401,
                          "cannot verify google id token"
                        } = Handler.login("token")
               end) =~ "unable to verify the google token: \"something failed\""
      end
    end

    test "/login failure - verify error" do
      with_mock(GoogleClient,
        verify_and_decode: fn id_token ->
          {:error, "something went wrong"}
        end
      ) do
        assert capture_log(fn ->
                 assert {
                          :error,
                          401,
                          "cannot verify google id token"
                        } = Handler.login("token")
               end) =~ "unable to verify the google token: \"something went wrong\""
      end
    end
  end
end
