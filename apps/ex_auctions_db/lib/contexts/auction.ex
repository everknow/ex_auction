defmodule ExAuctionsDB.Auction do
  @moduledoc """
  Bid schema
  """
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias ExAuctionsDB.DB

  require Logger

  @fields [
    :open,
    :expiration_date,
    :creation_date,
    :auction_base,
    :blind
  ]

  @required_fields @fields -- [:creation_date, :blind]

  @derive {Jason.Encoder, only: @fields ++ [:id]}
  schema "auctions" do
    field(:expiration_date, :utc_datetime)
    field(:creation_date, :utc_datetime)

    field(:expiration_date_int, :integer)
    field(:creation_date_int, :integer)

    field(:open, :boolean)
    field(:auction_base, :integer)
    field(:highest_bid, :integer)
    field(:highest_bidder, :string)
    field(:blind, :boolean, default: false)
  end

  def changeset(%__MODULE__{} = auction, attrs) do
    # Overriding any existing :creation_date and :open field values
    attrs =
      attrs
      |> Map.update(:open, true, fn _ -> true end)

    auction
    |> cast(attrs, [
      :open,
      :expiration_date,
      :expiration_date_int,
      :creation_date,
      :creation_date_int,
      :auction_base,
      :blind
    ])
    |> validate_required([
      :open,
      :expiration_date,
      :expiration_date_int,
      :creation_date,
      :creation_date_int,
      :auction_base
    ])
    |> validate_number(:auction_base, greater_than: 0, message: "auction_base must be positive")
    |> validate_expiration_date(:expiration_date)
  end

  defp validate_expiration_date(changeset, :expiration_date = field) do
    created = get_field(changeset, :creation_date)

    validate_change(changeset, field, fn _, expiration_date ->
      if Timex.compare(created, expiration_date) > -1 do
        [{field, "expiry date must be bigger than creation date"}]
      else
        []
      end
    end)
  end

  defp validate_expiration_date_int(changeset, :expiration_date_int = field) do
    created = get_field(changeset, :creation_date_int)

    validate_change(changeset, field, fn _, expiration_date_int ->
      if created >= expiration_date_int do
        [{field, "expiry date must be bigger than creation date"}]
      else
        []
      end
    end)
  end
end
