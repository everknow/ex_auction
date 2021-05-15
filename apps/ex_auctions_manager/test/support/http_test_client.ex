defmodule ExAuctionsManager.TestHTTPClient do
  @moduledoc false
  use Tesla, only: [:get]
  plug(Tesla.Middleware.BaseUrl, "http://localhost:10000")
end
