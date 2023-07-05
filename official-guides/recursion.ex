defmodule Recursion do
  def print_times(msg, n \\ 1)
  def print_times(_, 0), do: :ok
  def print_times(msg, n) when n > 0 do
    IO.puts msg
    print_times msg, n - 1
  end
end

# Recursion.print_times "Hello!", 3
# Recursion.print_times "Hello!", -1

defmodule Array do
  def sum(xs, start \\ 0)
  def sum([], start), do: start
  def sum([x | xs], start) when is_number(x) do
    sum xs, start + x
  end

  def double([]), do: []
  def double([x | xs]) when is_number(x) do
    [x * 2 | double xs]
  end
end

# Array.sum([1, 2, 3], 0) |> IO.puts
# Array.sum([1, 2, 3], 10) |> IO.puts
# Array.sum([1, 2, 3]) |> IO.puts

# Array.double([1, 2, 3]) |> IO.inspect
