defmodule ExContractCache.MemoryStore do
  @moduledoc """
  """
  @env (try do
          Mix.env() |> to_string()
        rescue
          _ -> "prod"
        end)
  @pages_key "pages"

  def store_pages(pages) do
    pipeline_commands = [["SET", full_key_name(@pages_key), pages |> Jason.encode!()]]
    {:ok, _} = Redix.transaction_pipeline(get_process_name(), pipeline_commands)
    :ok
  end

  def get_pages do
    result =
      case Redix.command(get_process_name(), ["GET", full_key_name(@pages_key)]) do
        {:ok, nil} ->
          nil

        {:ok, something} ->
          something |> Jason.decode!()
      end

    result
  end

  defp full_key_name(key) do
    "#{@env}::#{key}"
  end

  defp get_process_name do
    RedisInstance
  end
end
