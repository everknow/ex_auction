defmodule ExGate.SecretFetcher do
  @moduledoc """
  Guardian secrets fetcher implementation
  """
  @behaviour Guardian.Token.Jwt.SecretFetcher

  def fetch_signing_secret(_mod, _opts) do
    val = System.get_env("JWT_SECRET", "not so secret")
    {:ok, val}
  end

  def fetch_verifying_secret(_mod, _token_headers, _opts) do
    val = System.get_env("JWT_SECRET", "not so secret")
    {:ok, val}
  end
end
