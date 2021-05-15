defmodule ExAuctionsManager.TestHTTPClient do
  use Tesla, only: [:get]
  plug(Tesla.Middleware.BaseUrl, "http://localhost:10000")
end
