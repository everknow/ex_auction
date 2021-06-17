defmodule ExGate.MessageProcessor do
  def process(message) when is_bitstring(message) do
    message
    |> decode()
    |> evaluate_message()
  end

  defp decode(message) do
    case Jason.decode(message) do
      {:error, %Jason.DecodeError{} = err} -> {:error, err}
      other -> other
    end
  end

  defp evaluate_message({:ok, structured_message}) do
    case Jason.decode(message) do
      {:error, %Jason.DecodeError{} = err} -> {:error, err}
      other -> other
    end
  end

  defp evaluate_message({:error, err}) do
    {:error, err}
  end
end
