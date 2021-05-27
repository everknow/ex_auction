defmodule ExContractCache.MemoryStore do
  @moduledoc """
  Handles the communication to Redis
  """
  @behaviour ExContractCache.Behaviour.RedisBehaviour

  def store(pages) do
    pipeline_commands = [["SET", full_key_name("pages"), pages |> Jason.encode!()]]
    {:ok, _} = Redix.transaction_pipeline(get_process_name(), pipeline_commands)
    :ok
  end

  def get(key) do
    result =
      case Redix.command(get_process_name(), ["GET", full_key_name(key)]) do
        {:ok, nil} ->
          [[], [], [], "1"]

        {:ok, something} ->
          something |> Jason.decode!()
      end

    result
  end

  defp get_env do
    try do
      Mix.env() |> to_string()
    rescue
      _ -> "prod"
    end
  end

  defp full_key_name(key) do
    "#{get_env() <> "::"}#{key}"
  end

  defp get_process_name do
    RedisInstance
  end
end
