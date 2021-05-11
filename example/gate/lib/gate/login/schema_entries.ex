defmodule Gate.Login.SchemaEntries do
  def get(),
    do: %{
      example1: %{
        "type" => "object",
        "properties" => %{
          "id" => %{"type" => "string", "format" => "uuid"},
          "count" => %{"type" => "string", "format" => "numeric"},
          "name" => %{"type" => "string"}
        },
        "required" => ["id", "name"]
      },
      example2: %{
        "type" => "object",
        "properties" => %{
          "id" => %{"type" => "string", "format" => "uuid"},
          "meta" => %{
            "type" => "object",
            "properties" => %{
                "email" => %{"type" => "string", "format" => "email"},
                "link" => %{"type" => "string", "format" => "https"},
                "public_key" => %{"type" => "string", "format" => "rsa"}
            },
            "required" => ["email", "public_key"]
          }
        },
        "required" => ["id", "description"]
      },
      uuid: %{
        "type" => "string",
        "format" => "uuid"
      }
    }
end
