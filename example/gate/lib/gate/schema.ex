defmodule Gate.Schema do

  require Logger

  @schemas Gate.SchemaResolver.resolve(
    Application.get_env(:gate, :schema_parts, [])
  )

  @spec validate(atom(), ExJsonSchema.data()) :: boolean
  def validate(schema_id, data) do
    case Map.get(@schemas, schema_id) do
      nil ->
        Logger.error("#{__MODULE__} could not find schema #{schema_id}")
        false

      schema ->
        ExJsonSchema.Validator.valid?(schema, data) ## TODO check validate(root, data, options \\ []) for tracking erros?

    end
  end

end
