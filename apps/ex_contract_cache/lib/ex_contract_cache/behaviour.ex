defmodule ExContractCache.Behaviour.RedisBehaviour do
  @callback store([]) :: :ok
  @callback get(String.t()) :: any()
end
