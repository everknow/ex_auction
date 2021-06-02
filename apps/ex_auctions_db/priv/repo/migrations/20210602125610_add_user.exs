defmodule ExAuctionsDB.Repo.Migrations.AddUser do
  use Ecto.Migration

  def change do

    create table("user", primary_key: false) do
      add :username, :string, primary_key: true
      add :google_id, :string, null: false
    end

    create unique_index("user", [:google_id], name: :unique_google_id)
  end
end
