defmodule ExAuction.Login.Handler.Tests do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExAuction.Login.V1.Receiver
  alias ExAuction.GoogleClient

  import Mock

  @opts Receiver.init([])

  describe "Receiver tests" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get, url: "https://oauth2.googleapis.com/tokeninfo"} ->
          %Tesla.Env{status: 200, body: {:ok, "something"}}
      end)

      :ok
    end

    test "/ping" do
      conn = conn(:get, "/ping")

      conn = Receiver.call(conn, @opts)
      assert %{status: 200, state: :sent, resp_body: "pong"} = conn
    end

    test "/login success" do
      conn = conn("post", "/login", %{google_token: "some_token"})

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

    test "/login failure - google service not reachable" do
      conn = conn("post", "/login", %{google_token: "some_token"})

      with_mock(GoogleClient,
        verify: fn id_token ->
          {:error, 500, "something went wrong"}
        end
      ) do
        conn = Receiver.call(conn, @opts)

        assert %{
                 resp_body: response_body,
                 status: 500
               } = conn

        assert %{
                 "error" => "could not reach google service"
               } = response_body |> Jason.decode!()
      end
    end
  end
end
