defmodule LucasNumbers do
  @moduledoc """
  Lucas numbers are an infinite sequence of numbers which build progressively
  which hold a strong correlation to the golden ratio (φ or ϕ)

  E.g.: 2, 1, 3, 4, 7, 11, 18, 29, ...
  """
  def generate(1), do: [2]
  def generate(2), do: [2, 1]

  def generate(count) when is_integer(count) and count > 2 do
    Stream.iterate({2, 1}, &{elem(&1, 1), elem(&1, 0) + elem(&1, 1)})
    |> Stream.map(&(elem(&1, 0) + elem(&1, 1)))
    |> then(&Stream.concat(generate(2), &1))
    |> Stream.take(count)
    |> Enum.to_list()
  end

  def generate(_) do
    raise ArgumentError, "count must be specified as an integer >= 1"
  end
end
