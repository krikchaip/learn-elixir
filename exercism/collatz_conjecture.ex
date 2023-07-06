defmodule CollatzConjecture do
  def calc(1), do: 0
  def calc(n) when n > 0 and rem(n, 2) == 1, do: 1 + calc(3*n + 1)
  def calc(n) when n > 0 and rem(n, 2) == 0, do: 1 + calc(div n, 2)
end

# CollatzConjecture.calc(0) |> IO.puts
