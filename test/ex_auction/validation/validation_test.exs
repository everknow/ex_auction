defmodule ExAuction.Validation.Tests do
  use ExUnit.Case, async: true

  alias ExAuction.SchemaValidator

  describe "" do
    test "" do
      input_payload = Jason.encode!(%{"bid" => "1"})

      assert SchemaValidator.validate(:bid, input_payload)
    end
  end
end
