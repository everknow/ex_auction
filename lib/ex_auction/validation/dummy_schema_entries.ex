defmodule ExAuction.Dummy.SchemaEntries do
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
          "code" => %{"type" => "string", "format" => "uuid"}
        },
        "required" => ["name", "email", "code"]
      }
    }
  end
end
