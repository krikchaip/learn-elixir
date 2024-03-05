defmodule Knapsack do
  @doc """
  Return the maximum value that a knapsack can carry.
  """
  @spec maximum_value(
          items :: [%{value: integer, weight: integer}],
          maximum_weight :: integer
        ) :: integer
  def maximum_value(items, maximum_weight) do
    # recursive(items, maximum_weight)
    # memoize(items, maximum_weight)
    tabulate(items, maximum_weight)
  end

  defp recursive(_items = [], _w), do: 0
  defp recursive(_items, _w = 0), do: 0

  defp recursive([i | rest], w) when w < i.weight do
    recursive(rest, w)
  end

  defp recursive(items = [i | rest], w) do
    max(
      i.value + recursive(List.delete(items, i), w - i.weight),
      recursive(rest, w)
    )
  end

  defp memoize(items, w), do: %{} |> do_memoize(items, w) |> Map.get(w)

  defp do_memoize(result, _items = [], w), do: Map.put(result, w, 0)
  defp do_memoize(result, _items, _w = 0), do: Map.put(result, 0, 0)

  defp do_memoize(result, [i | rest], w) when w < i.weight do
    do_memoize(result, rest, w)
  end

  defp do_memoize(result, items = [i | rest], w) do
    select_i = do_memoize(result, List.delete(items, i), w - i.weight)
    ignore_i = do_memoize(result, rest, w)

    result = Map.merge(select_i, ignore_i, fn _, v1, v2 -> max(v1, v2) end)

    Map.put(result, w, max(i.value + result[w - i.weight], result[w]))
  end

  defp tabulate(items, w) do
    result =
      for i <- 0..length(items),
          w <- 0..w,
          into: %{},
          do: {{i, w}, 0}

    result =
      for i <- 1..length(items),
          w <- 1..w,
          item = Enum.at(items, i - 1),
          %{value: vi, weight: wi} = item,
          reduce: result do
        result when w < wi ->
          Map.put(result, {i, w}, result[{i - 1, w}])

        result ->
          Map.put(result, {i, w}, max(vi + result[{i - 1, w - wi}], result[{i - 1, w}]))
      end

    Map.get(result, {length(items), w})
  end
end
