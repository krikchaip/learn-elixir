defmodule KillerSudokuHelper do
  @type cage :: %{exclude: [integer], size: integer, sum: integer}

  @doc """
  Return the possible combinations of `size` distinct numbers from 1-9 excluding `exclude` that sum up to `sum`.
  """
  @spec combinations(cage) :: [[integer]]
  def combinations(cage) do
    combinations(cage, Enum.to_list(1..9) -- cage.exclude)
  end

  defp combinations(%{size: 0, sum: 0}, _pool), do: [[]]
  defp combinations(_cage, []), do: []

  defp combinations(cage, [n | rest]) do
    current_results =
      for choices <- combinations(decrement(cage, n), rest) do
        [n | choices]
      end

    current_results ++ combinations(cage, rest)
  end

  defp decrement(cage, n) do
    %{cage | size: cage.size - 1, sum: cage.sum - n}
  end
end
