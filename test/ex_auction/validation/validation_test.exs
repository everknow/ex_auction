defmodule ExAuction.Validation.Tests do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias ExAuction.SchemaValidator

  describe "Schema validation tests" do
    test "successful validation - receives string" do
      payload =
        %{"bid" => "1"}
        |> Jason.encode!()

      assert SchemaValidator.validate(:bid, payload)
    end

    test "successful validation - receives struct" do
      payload = %{"bid" => "1"}

      assert SchemaValidator.validate(:bid, payload)
    end

    test "failing validation - unrecognized schema" do
      input_payload = Jason.encode!(%{"bid" => "1"})

      assert capture_log(fn ->
               refute SchemaValidator.validate(:bids, input_payload)
             end) =~ "could not find schema: :bids"
    end

    test "failing validation - invalid json" do
      input_payload = "im_invalid"

      assert capture_log(fn ->
               refute SchemaValidator.validate(:bid, input_payload)
             end) =~ "unable to deserialize the json schema: #{input_payload}"
    end
  end
end
