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
        Logger.error("#{__MODULE__} unable to deserialize the json schema: #{data}")
        false
    end
  end

  def validate(schema_id, data) do
    get_schema(@schemas, schema_id)
    |> validate_schema(data)
  end

  defp get_schema(schemas, schema_id) do
    case Map.get(schemas, schema_id) do
      nil ->
        Logger.error("unable to find schema: #{inspect(schema_id)}")
        {:error, "schema_not_found"}

      schema ->
        {:ok, schema}
    end
  end

  def validate_schema({:ok, schema}, data) do
    case Validator.valid?(schema, data) do
      false -> log_validation_error_message(schema, data)
      true -> true
    end
  end

  def validate_schema({:error, "schema_not_found"}, data) do
    false
  end

  defp log_validation_error_message(schema, data) do
    {:error, errors_list} = Validator.validate(schema, data)

    errors_list
    |> Enum.each(fn {message, path} ->
      Logger.error(message <> " Path: " <> path)
    end)

    false
  end
end
