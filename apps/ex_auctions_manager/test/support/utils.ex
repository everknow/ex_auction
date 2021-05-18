defmodule TestUtils do
  def shift_datetime(start, days \\ 0, hours \\ 0, minutes \\ 0, seconds \\ 0) do
    start
    |> DateTime.add(days * 24 * 60 * 60, :second)
    |> DateTime.add(hours * 60 * 60, :second)
    |> DateTime.add(minutes * 60, :second)
    |> DateTime.add(seconds, :second)
  end

  def get_now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
