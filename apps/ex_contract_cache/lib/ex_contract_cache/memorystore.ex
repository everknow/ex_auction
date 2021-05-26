defmodule ExContractCache.MemoryStore do
  @behaviour ExContractCache.Behaviour.RedisBehaviour
  require Logger

  def store(pages) do
    pipeline_commands = [["SET", full_key_name("pages"), pages |> Jason.encode!()]]
    {:ok, _} = Redix.transaction_pipeline(RedixInstance, pipeline_commands)
    Logger.debug("pages stored")
    :ok
  end

  def get(key) do
    result =
      case Redix.command(RedixInstance, ["GET", full_key_name(key)]) do
        {:ok, nil} ->
          [[], [], [], "1"]

        {:ok, something} ->
          something |> Jason.decode!()
      end

    Logger.debug("Returning #{inspect(key)}")
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
end
