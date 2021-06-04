defmodule ExGate.Login.HandlerTests do
  use ExAuctionsDB.RepoCase, async: false
  use Plug.Test

  alias ExGate.GoogleClient
  alias ExGate.Login.Handler
  alias ExAuctionsDB.{DB, User}
  import ExUnit.CaptureLog
  import Mock

  require Logger

  describe "Handler tests" do
    test "/login success" do
      {:ok, %User{}} = DB.register_user("bruno.ripa@gmail.com", "brunoripa")

      with_mock(GoogleClient,
        verify_and_decode: fn _id_token ->
          {:ok,
           %{
             "aud" => Application.get_env(:ex_gate, :google_client_id),
             "email" => "bruno.ripa@gmail.com"
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
                  "sub" => "brunoripa",
                  "typ" => "access"
                }} = Handler.login("bruno.ripa@gmail.com")
      end
    end

    test "/login failure - unable to decode google payload" do
      with_mock(GoogleClient,
        verify_and_decode: fn _id_token ->
          {:error, "something failed"}
        end
      ) do
        assert capture_log(fn ->
                 assert {
                          :error,
                          401,
                          "unable to verify google token"
                        } = Handler.login("bruno.ripa@gmail.com")
               end) =~ "unable to verify google token"
      end
    end
  end
end
