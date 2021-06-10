defmodule ExAuctionsDB.AggregationTests do
  use ExUnit.Case

  alias ExAuctionsDB.DB

  describe "Aggregation tests" do
    test "" do
      data = [
        [2, "bruno.ripa@gmail.com", 1002],
        [3, "andrea.zorzi.94@gmail.com", 5600],
        [2, "bruno.ripa@polaris-br.com", 1001],
        [3, "andrea.zorzi.za@gmail.com", 5601],
        [3, "bruno.ripa@polaris-br.com", 1000],
        [3, "andrea", 350]
      ]

      assert %{2 => ["bruno.ripa@gmail.com", 1002], 3 => ["andrea.zorzi.za@gmail.com", 5601]} =
               data |> DB.aggregate_query_result()
    end
  end
end
