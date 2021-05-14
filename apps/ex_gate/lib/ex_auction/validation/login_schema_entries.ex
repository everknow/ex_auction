defmodule ExGate.Login.SchemaEntries do
  @moduledoc """
  Schema definitions
  """
  def get do
    %{
      bid: %{
        "type" => "object",
        "properties" => %{
          "bid" => %{"type" => "string"}
        },
        "required" => ["bid"]
      }
    }
  end
end
