defmodule ExGate.Login.ReceiverTests do
  use ExAuctionsDB.RepoCase, async: true
  use Plug.Test

  alias ExGate.Login.Handler
  alias ExGate.Login.V1.Receiver
  alias ExGate.GoogleClient
  alias ExAuctionsDB.{DB, User}

  import Mock

  @opts Receiver.init([])

  describe "Receiver tests" do
    test "/login success" do
      {:ok, %User{}} = DB.register_user("bruno.ripa@gmail.com", "brunoripa")
      conn = conn("post", "/", %{id_token: "bruno.ripa@gmail.com"})

      with_mock(GoogleClient,
        verify_and_decode: fn _id_token ->
          {:ok,
           %{
             "aud" => Application.get_env(:ex_gate, :google_client_id),
             "email" => "bruno.ripa@gmail.com"
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

    test "/login failure - unable to decode token" do
      conn = conn("post", "/", %{id_token: "some_token"})

      conn = Receiver.call(conn, @opts)

      assert %{
               resp_body: response_body,
               status: 401
             } = conn

      assert "unable to verify google token" = response_body |> Jason.decode!()
    end

    test "/login failure - user does not exist" do
      conn = conn("post", "/", %{id_token: "some_token"})

      with_mock(GoogleClient,
        verify_and_decode: fn _id_token ->
          {:ok,
           %{
             "aud" => Application.get_env(:ex_gate, :google_client_id),
             "email" => "bruno.ripa@gmail.com"
           }}
        end
      ) do
        conn = Receiver.call(conn, @opts)

        assert %{
                 resp_body: response_body,
                 status: 404
               } = conn

        assert "user does not exist" = response_body |> Jason.decode!()
      end
    end
  end
end
