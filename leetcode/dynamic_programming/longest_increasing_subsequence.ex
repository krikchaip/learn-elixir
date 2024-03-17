defmodule Solution do
  @spec length_of_lis(nums :: [integer]) :: integer
  def length_of_lis(nums) do
    # recursive(nums)
    memoize(nums)
    # tabulate(nums)
  end

  defp recursive(nums, last \\ -99999)

  defp recursive([], _last), do: 0

  defp recursive([n | nums], last) when n <= last do
    recursive(nums, last)
  end

  defp recursive([n | nums], last) do
    current = 1 + recursive(nums, n)
    rest = recursive(nums, last)

    max(current, rest)
  end

  defp memoize(nums) do
    %{}
    |> do_memoize(Enum.with_index(nums, &{&2, &1}), {-1, -99999})
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  defp do_memoize(cache, _nums, {j, _last}) when is_map_key(cache, j), do: cache

  defp do_memoize(cache, [], {j, _last}), do: Map.put(cache, j, 0)

  defp do_memoize(cache, [{_i, n} | nums], {j, last}) when n <= last do
    do_memoize(cache, nums, {j, last})
  end

  defp do_memoize(cache, [{i, n} | nums], {j, last}) do
    current = do_memoize(cache, nums, {i, n})
    rest = do_memoize(current, nums, {j, last})

    Map.put(rest, j, max(1 + rest[i], rest[j]))
  end

  defp tabulate([_]), do: 1

  defp tabulate(nums) do
    nums_map = Map.new(Enum.with_index(nums, &{&2, &1}))
    last_idx = map_size(nums_map) - 1

    init = for(i <- 0..last_idx, into: %{}, do: {i, 1})

    answer =
      for i <- 0..(last_idx - 1),
          j <- (i + 1)..last_idx,
          nums_map[i] < nums_map[j],
          reduce: init do
        answer ->
          Map.put(answer, j, max(1 + answer[i], answer[j]))
      end

    Enum.max(Map.values(answer))
  end
end
