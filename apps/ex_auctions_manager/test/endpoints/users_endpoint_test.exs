defmodule ExAuctionsDB.UsersEndpointTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{DB, User}

  describe "Users endpoint" do
    setup do
      email = "email@domain.com"

      assert {:ok, %User{google_id: email} = user} = DB.register_user(email, "username")

      {:ok, %{user: user}}
    end

    test "link wallet to user", %{user: %User{google_id: user_id}} do
      wallet = "wallet"

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: user_id},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 200, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/users/#{user_id}/wallet/#{wallet}",
                 %{} |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert {:ok, %User{wallet: ^wallet}} = DB.get_user(user_id)
    end

    test "link wallet to user - unknown user" do
      wallet = "wallet"
      user_id = "i_dont_exist"

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: user_id},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 422, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/users/#{user_id}/wallet/#{wallet}",
                 %{} |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )
    end

    test "link wallet to user - wallet already taken" do
      wallet = "wallet"
      user_id = "user-id"
      username = "username"

      user =
        %User{}
        |> User.changeset(%{google_id: user_id, username: username, wallet: wallet})

      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: user_id},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      assert {:ok, %Tesla.Env{status: 422, body: body}} =
               Tesla.post(
                 Tesla.client([]),
                 "http://localhost:10000/api/v1/users/#{user_id}/wallet/#{wallet}",
                 %{} |> Jason.encode!(),
                 headers: [
                   {"authorization", "Bearer #{token}"},
                   {"content-type", "application/json"}
                 ]
               )

      assert "unable to execute" = Jason.decode!(body)
    end
  end
end
