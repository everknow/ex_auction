defmodule ExAuction.SchemaValidator do
  @moduledoc """
  SchemaValidator: single entrypoint for validation logic
  """

  alias ExAuction.SchemaResolver
  alias ExJsonSchema.Validator

  require Logger

  @schemas SchemaResolver.resolve(Application.get_env(:ex_auction, :schema_parts, []))

  def validate(schema_id, data) when is_bitstring(data) do
    Logger.debug("1")

    case Jason.decode(data) do
      {:ok, decoded} ->
        validate(schema_id, decoded)

      {:error, _} ->
        Logger.error("#{__MODULE__} unable to deserialize the json schema: #{data}")
        false
    end
  end

  def validate(schema_id, data) do
    Logger.debug("2")

    case Map.get(@schemas, schema_id) do
      nil ->
        Logger.error("#{__MODULE__} could not find schema: #{inspect(schema_id)}")
        false

      schema ->
        Logger.debug("Schema detected: #{inspect(schema)} for data: #{inspect(data)}")
        ## TODO check validate(root, data, options \\ []) for tracking erros?
        # Validator.valid?(schema, data)
        Validator.validate(schema, data) |> IO.inspect(label: "-------")
    end
  end
end
