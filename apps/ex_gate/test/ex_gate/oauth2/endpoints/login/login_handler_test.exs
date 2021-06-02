defmodule ExGate.Login.HandlerTests do
  use ExUnit.Case, async: false
  use Plug.Test

  alias ExGate.GoogleClient
  alias ExGate.Login.Handler

  import ExUnit.CaptureLog
  import Mock

  require Logger

  describe "Handler tests" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExAuctionsDB.Repo)
      # Setting the shared mode must be done only after checkout
      Ecto.Adapters.SQL.Sandbox.mode(ExAuctionsDB.Repo, {:shared, self()})
    end

    test "/login success" do
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
                  "sub" => "bruno.ripa@gmail.com",
                  "typ" => "access"
                }} = Handler.login("token", "bruno.ripa@gmail.com")
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
                          "cannot verify google id token"
                        } = Handler.login("token", "bruno.ripa@gmail.com")
               end) =~ "unable to verify the google token: \"something failed\""
      end
    end

    test "/login failure - verify error" do
      with_mock(GoogleClient,
        verify_and_decode: fn _id_token ->
          {:error, "something went wrong"}
        end
      ) do
        assert capture_log(fn ->
                 assert {
                          :error,
                          401,
                          "cannot verify google id token"
                        } = Handler.login("token", "bruno.ripa@gmail.com")
               end) =~ "unable to verify the google token: \"something went wrong\""
      end
    end
  end
end
