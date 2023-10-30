# Possible Approaches:
#   Greedy with Backtracking (current implementation)
#     - https://exercism.org/tracks/elixir/exercises/change/solutions/muhifauzan
#   Dynamic Programming (bottom-up)
#     - https://exercism.org/tracks/elixir/exercises/change/solutions/rewritten
#     - https://exercism.org/tracks/elixir/exercises/change/solutions/rslopes

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
    do_generate(Enum.reverse(coins), target, [], {[], []})
  end

  # can change but no further possible combinations
  defp do_generate(_, 0, changes, {[], _}) do
    {:ok, changes}
  end

  # can change but there are more possible combinations
  defp do_generate(_, 0, changes, {checkpoints, _}) do
    [{prev_coins, prev_target, prev_changes} | checkpoints] = checkpoints
    do_generate(prev_coins, prev_target, prev_changes, {checkpoints, changes})
  end

  # can not change at all (no further possible combinations, no previous result)
  defp do_generate([], _, _, {[], []}) do
    {:error, "cannot change"}
  end

  # can not change but there is already some combination that can
  defp do_generate([], _, _, {[], min_changes}) do
    {:ok, min_changes}
  end

  # can not change but there are possible combinations that can
  defp do_generate([], _, _, {checkpoints, min_changes}) do
    [{prev_coins, prev_target, prev_changes} | checkpoints] = checkpoints
    do_generate(prev_coins, prev_target, prev_changes, {checkpoints, min_changes})
  end

  # can not change with the current coin, use the next coin
  defp do_generate([c | rest], target, changes, {checkpoints, min_changes}) when c > target do
    do_generate(rest, target, changes, {checkpoints, min_changes})
  end

  # still in the process of finding possible combinations (no result yet)
  defp do_generate([c | rest] = coins, target, changes, {checkpoints, []}) do
    checkpoints = [{rest, target, changes} | checkpoints]
    do_generate(coins, target - c, [c | changes], {checkpoints, []})
  end

  # can change with the current coin but won't go further because it will result in sub-optimal combination
  defp do_generate(_, _, changes, {checkpoints, min_changes}) when length(changes) >= length(min_changes) do
    [{prev_coins, prev_target, prev_changes} | checkpoints] = checkpoints
    do_generate(prev_coins, prev_target, prev_changes, {checkpoints, min_changes})
  end

  # can change with the current coin, mark checkpoint just in case when this combination is not valid
  defp do_generate([c | rest] = coins, target, changes, {checkpoints, min_changes}) do
    checkpoints = [{rest, target, changes} | checkpoints]
    do_generate(coins, target - c, [c | changes], {checkpoints, min_changes})
  end
end
