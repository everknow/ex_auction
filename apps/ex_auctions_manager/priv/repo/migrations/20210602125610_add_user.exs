defmodule ExAuctionsManager.Repo.Migrations.AddUser do
  use Ecto.Migration

  def change do

    create table("user", primary_key: false) do
      add :username, :string, primary_key: true
      add :google_id, :string, null: false
    end

    create unique_index("user", [:username, :google_id])
  end
end
