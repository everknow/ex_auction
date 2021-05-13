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
             end) =~ "unable to find schema: :bids"
    end

    test "failing validation - invalid json" do
      input_payload = "im_invalid"

      assert capture_log(fn ->
               refute SchemaValidator.validate(:bid, input_payload)
             end) =~ "unable to deserialize the json schema: #{input_payload}"
    end
  end

  describe "Dummy validation tests" do
    test "success" do
      %{
        "name" => "Bruno",
        "email" => "bruno.ripa@gmail.com",
        "code" => UUID.uuid4() |> to_string()
      }
      |> (fn p -> SchemaValidator.validate(:dummy, p) end).()
    end

    test "failure because code is not in the correct format" do
      p = %{
        "name" => "Bruno",
        "email" => "bruno",
        "code" => "1"
      }

      capture_log(fn ->
        refute SchemaValidator.validate(:dummy, p)
      end) =~ "Expected to be a valid uuid. Path: #/code"
    end

    test "failure by multiple fields mismatch - name missing and code in the wrong format" do
      p = %{
        "email" => "bruno.ripa@gmail.com",
        "code" => "1"
      }

      result =
        capture_log(fn ->
          refute SchemaValidator.validate(:dummy, p)
        end)

      assert result =~ "Required property name was not present."
      assert result =~ "Expected to be a valid uuid. Path: #/code"
    end
  end
end
