defmodule ExAuctionsManager.UserSchemaTests do
  use ExAuctionsManager.RepoCase, async: false

  alias ExAuctionsManager.{DB, User}

  describe "User schema tests" do
    test "user creation" do
      assert {:ok, %User{}} = DB.register_username("brunoripa2", "bruno.ripa2@gmail.com")

      assert {:error, %Ecto.Changeset{valid?: false}} =
               DB.register_username("brunoripa2", "bruno.ripa2@gmail.com")
    end
  end
end
