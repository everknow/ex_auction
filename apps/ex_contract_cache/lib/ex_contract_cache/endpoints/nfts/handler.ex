defmodule ExContractCache.Endpoints.NFT.Handler do
  # TODO: This  must be in the config

  alias ExContractCache.TraverseAndAggregate

  def list_nfts(start_index, limit, owner_address) do
    nfts = TraverseAndAggregate.get_nfts()
  end
end
