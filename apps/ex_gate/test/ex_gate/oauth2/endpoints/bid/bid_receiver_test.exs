defmodule ExGate.Bid.Receiver.Tests do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExGate.Bid.Handler
  alias ExGate.Bid.V1.Receiver
  alias ExGate.GoogleClient

  import ExUnit.CaptureLog
  import Mock

  @opts Receiver.init([])

  describe "Receiver tests" do
    test "/v1/bid success" do
      {:ok, token, _claims} =
        ExGate.Guardian.encode_and_sign(
          _resource = %{user_id: "1"},
          _claims = %{},
          # GOOGLE EXPIRY: decoded["exp"]
          _opts = [ttl: {3600, :seconds}]
        )

      conn =
        conn("post", "/", %{"bid" => "1"})
        |> put_req_header("authorization", "Bearer #{token}")
        |> put_req_header("content-type", "application/json")

      assert %{status: 200, resp_body: response} = Receiver.call(conn, @opts)
      assert %{"bid" => "success"} = Jason.decode!(response)
    end

    test "/v1/bid failure - 401" do
      token = "invalid_token"

      conn =
        conn("post", "/", %{"bid" => "1"})
        |> put_req_header("authorization", "Bearer #{token}")
        |> put_req_header("content-type", "application/json")

      assert %{status: 401} = Receiver.call(conn, @opts)
    end

    test "/v1/bid failure - invalid payload" do
      # TBD
    end
  end
end
