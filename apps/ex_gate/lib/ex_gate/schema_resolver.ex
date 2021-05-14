defmodule ExGate.SchemaResolver do
  @moduledoc false
  def resolve(modules) do
    modules
    |> Enum.reduce(%{}, fn m, acc -> Map.merge(acc, m.get()) end)
    |> Enum.map(fn {k, v} -> {k, ExJsonSchema.Schema.resolve(v)} end)
    |> Enum.into(%{})
  end
end
