defmodule ExAuctionsDB.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  @primary_key {:google_id, :string, autogenerate: false}
  schema "user" do
    field(:username, :string, null: false)
    field(:wallet, :string, null: true, default: "")
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :google_id,
      :wallet
    ])
    |> validate_required([
      :username,
      :google_id
    ])
    |> unique_constraint([:username], name: :unique_username)
    |> unique_constraint([:wallet], name: :unique_wallet)
    |> unique_constraint(:google_id, name: :user_pkey)
  end
end
