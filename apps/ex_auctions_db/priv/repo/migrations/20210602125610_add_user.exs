defmodule ExAuctionsDB.Repo.Migrations.AddUser do
  use Ecto.Migration

  def change do

    create table("user", primary_key: false) do
      add :google_id, :string, primary_key: true
      add :username, :string, null: false
    end

    create unique_index("user", [:username], name: :unique_username)
  end
end
