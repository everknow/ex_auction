defmodule ExGate.Register.ReceiverTests do
  use ExAuctionsDB.RepoCase, async: true
  use Plug.Test

  alias ExAuctionsDB.{DB, User}
  alias ExGate.GoogleClient
  alias ExGate.Register.Receiver

  import Mock

  @opts Receiver.init([])

  describe "Receiver tests" do
    test "/register success" do
      conn = conn("post", "/", %{id_token: "token", username: "brunoripa"})

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

    test "/register failure - unable to decode token" do
      conn = conn("post", "/", %{id_token: "some_token", username: "brunoripa"})

      conn = Receiver.call(conn, @opts)

      assert %{
               resp_body: response_body,
               status: 401
             } = conn

      assert "unable to verify google token" = response_body |> Jason.decode!()
    end

    test "/register failure - user already exists" do
      {:ok, %User{}} = DB.register_user("bruno.ripa@gmail.com", "brunoripa")

      conn = conn("post", "/", %{id_token: "token", username: "brunoripa"})

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
                 status: 422
               } = conn

        assert "username already registered" = response_body |> Jason.decode!()
      end
    end
  end
end
