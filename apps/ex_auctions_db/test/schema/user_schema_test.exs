defmodule ExAuctionsDB.UserSchemaTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{DB, User}

  describe "User schema tests" do
    test "user creation" do
      assert {:ok, %User{}} = DB.register_username("brunoripa2", "bruno.ripa2@gmail.com")

      assert {:error, %Ecto.Changeset{valid?: false}} =
               DB.register_username("brunoripa2", "bruno.ripa2@gmail.com")
    end
  end
end
