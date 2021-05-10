defmodule Gate.Protected.Handler do

  def init(), do: :ok

  def ping(), do: "pong"

  def ping(_context), do: "pong"

end
