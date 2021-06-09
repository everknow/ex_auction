defmodule ExAuctionsDB.UserSchemaTests do
  use ExAuctionsDB.RepoCase, async: false

  alias ExAuctionsDB.{DB, User}

  describe "User schema tests" do
    test "idempotent user creation" do
      assert {:ok, %User{}} = DB.register_user("bruno.ripa2@gmail.com", "brunoripa2")

      assert {:error, "username already registered"} =
               DB.register_user("bruno.ripa3@gmail.com", "brunoripa2")
    end
  end
end
