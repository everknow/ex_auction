defmodule ExAuctionsManager.TestHTTPClient do
  @moduledoc false
  use Tesla, only: [:get, :post]
  plug(Tesla.Middleware.BaseUrl, "http://localhost:10000")
end
