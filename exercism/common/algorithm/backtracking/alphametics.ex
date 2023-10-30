# Possible Approaches:
#   Leverage Enum.find_value/2 for Backtracking (current implementation)
#     - https://exercism.org/tracks/elixir/exercises/alphametics/solutions/rslopes
#   Generates permutations and look for the correct solution
#     - https://exercism.org/tracks/elixir/exercises/alphametics/solutions/mstranger

defmodule Alphametics do
  @type puzzle :: binary
  @type solution :: %{required(?A..?Z) => 0..9}

  @doc """
  Takes an alphametics puzzle and returns a solution where every letter
  replaced by its number will make a valid equation. Returns `nil` when
  there is no valid solution to the given puzzle.

  ## Examples

    iex> Alphametics.solve("I + BB == ILL")
    %{?I => 1, ?B => 9, ?L => 0}

    iex> Alphametics.solve("A == B")
    nil
  """
  @spec solve(puzzle) :: solution | nil
  def solve(puzzle) do
    {addends, total} = parse_equation(puzzle)

    all_letters = [total | addends] |> List.flatten() |> Enum.uniq()
    first_letters = [hd(total) | Enum.map(addends, &hd/1)] |> Enum.uniq()

    solve(addends, total, {all_letters, first_letters, %{}, Enum.to_list(0..9)})
  end

  # Check whether a given solution is correct after filled all the letters with numbers
  defp solve(addends, total, {[], _first_letters, solution, _pool}) do
    validate_solution(solution, addends, total)
  end

  # Traverse all the values in the pool and pinpoint the correct ones
  defp solve(addends, total, {[l | all_letters], first_letters, solution, pool}) do
    Enum.find_value(pool, fn n ->
      leading_zero? = l in first_letters and n == 0

      unless leading_zero? do
        solution = put_in(solution[l], n)
        pool = List.delete(pool, n)

        solve(addends, total, {all_letters, first_letters, solution, pool})
      end
    end)
  end

  defp parse_equation(puzzle) do
    [sum, total] = puzzle |> String.replace(" ", "") |> String.split("==")

    addends = sum |> String.split("+") |> Enum.map(&to_charlist/1)
    total = to_charlist(total)

    {addends, total}
  end

  defp validate_solution(solution, addends, total) do
    [total | addends]
    |> Enum.map(fn letters -> Enum.map(letters, &solution[&1]) end)
    |> Enum.map(&Integer.undigits/1)
    |> then(&if hd(&1) == Enum.sum(tl(&1)), do: solution)
  end
end
