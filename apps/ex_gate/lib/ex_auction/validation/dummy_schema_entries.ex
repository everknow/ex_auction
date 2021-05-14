defmodule ExGate.Dummy.SchemaEntries do
  @moduledoc """
  Schema definitions
  """
  def get do
    %{
      dummy: %{
        "type" => "object",
        "properties" => %{
          "name" => %{"type" => "string"},
          "email" => %{"type" => "string"},
          "code" => %{"type" => "string", "format" => "uuid"},
          "nested" => %{
            "type" => "object",
            "properties" => %{
              "active" => %{"type" => "string", "format" => "boolean"}
            },
            "required" => ["active"]
          }
        },
        "required" => ["name", "email", "code", "nested"]
      }
    }
  end
end
