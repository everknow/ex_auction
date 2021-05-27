defmodule ExContractCacheTest.RedisSinglePageTests do
  use ExUnit.Case

  import Mock

  alias ExContractCache.{MemoryStore, TraverseAndAggregate, NFTFetcher}

  @page_1 [
    [
      "0xa92a9268b82c3cc37e4a38d7355d35cf7a442bf8",
      "0x42505aea1fd06aeb289058abb8c05a6539909822",
      "0x42505aea1fd06aeb289058abb8c05a6539909822",
      "0xb630f90d5a0df24ed4a44b5ca4980334f2e34ff8",
      "0xb630f90d5a0df24ed4a44b5ca4980334f2e34ff8",
      "0x42505aea1fd06aeb289058abb8c05a6539909822",
      "0xb630f90d5a0df24ed4a44b5ca4980334f2e34ff8",
      "0xb630f90d5a0df24ed4a44b5ca4980334f2e34ff8",
      "0xb630f90d5a0df24ed4a44b5ca4980334f2e34ff8",
      "0xb630f90d5a0df24ed4a44b5ca4980334f2e34ff8"
    ],
    [
      "e938b03d59841fe44413c25b0d4d56cac4ae0d7d39fbe928af3b55096d5f4f38",
      "e938b03d59841fe44413c25b0d4d56cac4ae0d7d39fbe928af3b55096d5f4f38",
      "e938b03d59841fe44413c25b0d4d56cac4ae0d7d39fbe928af3b55096d5f4f38",
      "e938b03d59841fe44413c25b0d4d56cac4ae0d7d39fbe928af3b55096d5f4f38",
      "e938b03d59841fe44413c25b0d4d56cac4ae0d7d39fbe928af3b55096d5f4f38",
      "1007a21f76fb695cda27b770ce7e52dcd937c62053c3d8eb722a83e83d1906d1",
      "1007a21f76fb695cda27b770ce7e52dcd937c62053c3d8eb722a83e83d1906d1",
      "1007a21f76fb695cda27b770ce7e52dcd937c62053c3d8eb722a83e83d1906d1",
      "1007a21f76fb695cda27b770ce7e52dcd937c62053c3d8eb722a83e83d1906d1",
      "1007a21f76fb695cda27b770ce7e52dcd937c62053c3d8eb722a83e83d1906d1"
    ],
    [
      "10000000000000000",
      "40000000000000000",
      "0",
      "10000000000000000",
      "10000000000000000",
      "40000000000000000",
      "20000000000000000",
      "20000000000000000",
      "20000000000000000",
      "20000000000000000"
    ],
    "11"
  ]

  @page_4 [
    [
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000"
    ],
    [
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000",
      "0000000000000000000000000000000000000000000000000000000000000000"
    ],
    ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0"],
    "11"
  ]
  require Logger

  def check_process() do
    pid = TraverseAndAggregate.get_process_name() |> Process.whereis()

    with false <- Process.alive?(pid) do
      :timer.sleep(100)
      check_process()
    end
  end

  def reset_agent() do
    pid = TraverseAndAggregate.get_process_name() |> Process.whereis()
    true = Process.exit(pid, :kill)

    check_process()
  end

  describe "TraverseAndAggregate Tests - single page test" do
    setup do
      pid = TraverseAndAggregate.get_process_name() |> Process.whereis()
      reset_agent()
      {:ok, _} = Redix.command(RedisInstance, ["DEL", "test::pages"])
      :ok
    end

    test "traversal" do
      with_mocks([
        {NFTFetcher, [:passthrough],
         [
           fetch: fn index, _size ->
             Logger.debug("Index: #{index}")

             case index do
               1 -> @page_1
               _ -> @page_4
             end
           end
         ]}
      ]) do
        pid = start_supervised!({TraverseAndAggregate, [name: TAATest]})

        assert is_pid(pid)
        :timer.sleep(1000)
        assert @page_1 = MemoryStore.get_pages()
      end
    end
  end
end
