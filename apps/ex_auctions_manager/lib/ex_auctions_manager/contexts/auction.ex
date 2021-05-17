defmodule ExAuctionsManager.Auction do
  @moduledoc """
  Bid schema
  """
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsManager.DB

  require Logger

  @fields [
    :open,
    :duration,
    :created
  ]

  @required_fields @fields -- [:created]

  @derive {Jason.Encoder, only: @required_fields}
  schema "auctions" do
    field(:open, :boolean)
    field(:duration, :integer)
    field(:created, :utc_datetime)
    field(:auction_base, :float)
  end

  def changeset(%__MODULE__{} = auction, attrs) do
    # Overriding any existing :created and :open field values
    attrs =
      attrs
      |> Map.update(:created, DateTime.utc_now(), fn _ -> DateTime.utc_now() end)
      |> Map.update(:open, true, fn _ -> true end)

    auction
    |> cast(attrs, [
      :open,
      :duration,
      :created,
      :auction_base
    ])
    |> validate_required([
      :open,
      :duration,
      :created,
      :auction_base
    ])
    |> validate_duration(:duration)
  end

  defp validate_duration(changeset, :duration = field, opts \\ []) do
    validate_change(changeset, field, fn _, auction_duration ->
      if auction_duration <= 0 do
        [{field, opts[field] || "duration cannot be non-positive"}]
      else
        []
      end
    end)
  end
end
