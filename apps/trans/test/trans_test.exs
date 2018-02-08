defmodule TransTest do
  use ExUnit.Case
  doctest Trans

  test "greets the world" do
    assert Trans.hello() == :world
  end
end
