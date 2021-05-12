defmodule ExAuction.SchemaValidator do
  @moduledoc """
  SchemaValidator: single entrypoint for validation logic
  """

  alias ExAuction.SchemaResolver
  alias ExJsonSchema.Validator

  require Logger

  @schemas SchemaResolver.resolve(Application.compile_env(:ex_auction, :schema_parts, []))

  def validate(schema_id, data) when is_bitstring(data) do
    case Jason.decode(data) do
      {:ok, decoded} ->
        validate(schema_id, decoded)

      {:error, _} ->
        Logger.error("unable to deserialize the json schema")
        false
    end
  end

  def validate(schema_id, data) do
    case Map.get(@schemas, schema_id) do
      nil ->
        Logger.error("#{__MODULE__} could not find schema #{inspect(schema_id)}")
        false

      schema ->
        Logger.debug("Schema detected: #{inspect(schema)} for data: #{inspect(data)}")
        ## TODO check validate(root, data, options \\ []) for tracking erros?
        Validator.valid?(schema, data)
    end
  end
end
