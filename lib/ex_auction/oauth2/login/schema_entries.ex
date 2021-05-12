defmodule ExAuction.Login.SchemaEntries do
  def get() do
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
