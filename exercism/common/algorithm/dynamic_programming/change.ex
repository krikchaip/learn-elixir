defmodule Change do
  @doc """
    Determine the least number of coins to be given to the user such
    that the sum of the coins' value would equal the correct amount of change.
    It returns {:error, "cannot change"} if it is not possible to compute the
    right amount of coins. Otherwise returns the tuple {:ok, list_of_coins}

    ## Examples

      iex> Change.generate([5, 10, 15], 3)
      {:error, "cannot change"}

      iex> Change.generate([1, 5, 10], 18)
      {:ok, [1, 1, 1, 5, 10]}

  """

  @spec generate(list, integer) :: {:ok, list} | {:error, String.t()}
  def generate(coins, target) do
    # change = recursive(coins, target)
    change = memoize(coins, target)
    # change = tabulate(coins, target)

    if is_nil(change), do: {:error, "cannot change"}, else: {:ok, change}
  end

  defp recursive(_coins, 0), do: []

  defp recursive(coins, target) do
    coins
    |> Enum.reject(&(&1 > target))
    |> Enum.flat_map(fn c ->
      change = recursive(coins, target - c)
      if is_nil(change), do: [], else: [[c | change]]
    end)
    |> Enum.min_by(&length/1, fn -> nil end)
  end

  defp memoize(coins, target) do
    init_cache = Map.new([{0, []} | for(c <- coins, do: {c, [c]})])
    cache = do_memoize(init_cache, coins, target)

    # IO.inspect(cache, label: "\nCache", charlists: :as_lists)

    cache[target]
  end

  defp do_memoize(cache, _coins, target) when is_map_key(cache, target), do: cache

  defp do_memoize(cache, coins, target) do
    coins
    |> Enum.reject(&(&1 > target))
    |> Enum.reduce(Map.put(cache, target, nil), fn c, acc_cache ->
      new_cache = do_memoize(acc_cache, coins, target - c)
      change = new_cache[target - c]

      cond do
        # no answer for coin c, proceed with the cache from previous discoveries
        is_nil(change) ->
          new_cache

        # an answer exists for coin c, but there are no prior discoveries
        is_nil(new_cache[target]) ->
          Map.put(new_cache, target, [c | change])

        true ->
          prev_answer = new_cache[target]
          candidate = [c | change]
          new_answer = Enum.min_by([prev_answer, candidate], &length/1)

          Map.put(new_cache, target, new_answer)
      end
    end)
  end

  defp tabulate(_coins, 0), do: []

  defp tabulate(coins, target) do
    init_cache =
      for(
        t <- 1..target,
        into: %{0 => []},
        do: {t, if(t in coins, do: [t])}
      )

    cache =
      for t <- 1..target//1,
          c <- coins,
          c <= t,
          rest = t - c,
          reduce: init_cache do
        %{^rest => nil} = cache ->
          cache

        %{^rest => change, ^t => nil} = cache ->
          Map.put(cache, t, [c | change])

        %{^rest => change, ^t => prev_answer} = cache ->
          candidate = [c | change]
          new_answer = Enum.min_by([prev_answer, candidate], &length/1)

          Map.put(cache, t, new_answer)
      end

    # IO.inspect(cache, label: "\nCache", charlists: :as_lists)

    cache[target]
  end
end
