defmodule ElixirRedisgraphClientTest do
  use ExUnit.Case
  doctest ElixirRedisgraphClient

  test "greets the world" do
    assert ElixirRedisgraphClient.hello() == :world
  end
end
