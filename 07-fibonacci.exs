defmodule Fib do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n-1) + fib(n-2)
end
ExUnit.start
defmodule FibTest do
  use ExUnit.Case

  import Fib
  import FibFast

  test "fib" do
    assert fib(0) == 0
    assert fib(1) == 1
    assert fib(10) == 55
  end

  test "benchmark" do
    {microsecs, _} = :timer.tc fn -> fib(30) end
    IO.puts "fib() took #{microsecs} microsecs"
  end
end
