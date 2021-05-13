defmodule ExAuction.CustomValidator do
  @numeric_regex ~r/^[0-9]+$/

  @uuid_regex ~r/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/

  @https_regex ~r/^https\:\/\//

  @boolean_regex ~r/^(true|false)$/

  require Logger

  def validate("rsa", data), do: [] != :public_key.pem_decode(data)

  def validate("numeric", data), do: Regex.match?(@numeric_regex, data)

  def validate("uuid", data) do
    Logger.debug("Executing UUID validator")
    Regex.match?(@uuid_regex, data)
  end

  def validate("https", data), do: Regex.match?(@https_regex, data)

  def validate("boolean", data), do: Regex.match?(@boolean_regex, data)
end
