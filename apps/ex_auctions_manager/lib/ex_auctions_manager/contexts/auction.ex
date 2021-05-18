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
    :expiration_date,
    :creation_date
  ]

  @required_fields @fields -- [:creation_date]

  @derive {Jason.Encoder, only: @required_fields}
  schema "auctions" do
    field(:expiration_date, :utc_datetime)
    field(:creation_date, :utc_datetime)
    field(:open, :boolean)
    field(:auction_base, :integer)
    field(:highest_bid, :integer)
    field(:highest_bidder, :string)
  end

  def changeset(%__MODULE__{} = auction, attrs) do
    # Overriding any existing :creation_date and :open field values
    attrs =
      attrs
      |> Map.update(:creation_date, DateTime.utc_now(), fn _ -> DateTime.utc_now() end)
      |> Map.update(:open, true, fn _ -> true end)

    auction
    |> cast(attrs, [
      :open,
      :expiration_date,
      :creation_date,
      :auction_base
    ])
    |> validate_required([
      :open,
      :expiration_date,
      :creation_date,
      :auction_base
    ])
    |> validate_expiration_date(:expiration_date)
  end

  defp validate_expiration_date(changeset, :expiration_date = field, opts \\ []) do
    created = get_field(changeset, :creation_date)

    validate_change(changeset, field, fn _, expiration_date ->
      if created >= expiration_date do
        [{field, opts[field] || "expiry date must be bigger then creation date"}]
      else
        []
      end
    end)
  end
end
