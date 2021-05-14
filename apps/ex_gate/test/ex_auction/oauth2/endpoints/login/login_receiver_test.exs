defmodule ExGate.Login.Receiver.Tests do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExGate.GoogleClient
  alias ExGate.Login.Handler
  alias ExGate.Login.V1.Receiver

  import ExUnit.CaptureLog
  import Mock

  @opts Receiver.init([])

  describe "Receiver tests" do
    test "/ping" do
      assert %{status: 200, state: :sent} = conn("get", "/ping") |> Receiver.call(@opts)
    end

    test "/login success" do
      conn = conn("post", "/login", %{google_token: "some_token"})

      with_mock(Handler,
        login: fn id_token ->
          {:ok, "some_token", :stuff}
        end
      ) do
        conn = Receiver.call(conn, @opts)

        assert %{
                 resp_body: response_body,
                 status: 200
               } = conn

        assert %{
                 "access_token" => _,
                 "expires_in" => 3600,
                 "token_type" => "Bearer"
               } = response_body |> Jason.decode!()
      end
    end

    test "/login failure" do
      conn = conn("post", "/login", %{google_token: "some_token"})

      with_mock(Handler,
        login: fn id_token ->
          {:error, 500, "something went wrong"}
        end
      ) do
        assert capture_log(fn ->
                 conn = Receiver.call(conn, @opts)

                 assert %{
                          resp_body: response_body,
                          status: 500
                        } = conn

                 assert %{
                          "error" => "something went wrong"
                        } = response_body |> Jason.decode!()
               end) =~ "unable to login: code: 500 description: \"something went wrong\""
      end
    end
  end
end
