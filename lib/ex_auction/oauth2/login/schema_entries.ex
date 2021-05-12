defmodule ExAuction.Login.SchemaEntries do
  require Logger

  def get() do
    Logger.error("-----------------")

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
