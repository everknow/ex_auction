defmodule KmTest do
  use ExUnit.Case
  doctest Km

  test "greets the world" do
    assert Km.hello() == :world
  end
end
