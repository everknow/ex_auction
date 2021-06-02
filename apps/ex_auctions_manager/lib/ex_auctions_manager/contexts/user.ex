defmodule ExAuctionsManager.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  @primary_key {:username, :string, autogenerate: false}
  schema "user" do
    field(:google_id, :string)
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :google_id
    ])
    |> validate_required([
      :username,
      :google_id
    ])
  end
end
