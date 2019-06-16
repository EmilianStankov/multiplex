defmodule MultiplexTest do
  use ExUnit.Case
  doctest Multiplex

  test "greets the world" do
    assert Multiplex.hello() == :world
  end
end
