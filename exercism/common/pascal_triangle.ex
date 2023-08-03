defmodule PascalsTriangle do
  @doc """
  Calculates the rows of a pascal triangle
  with the given height
  """
  @spec rows(integer) :: [[integer]]
  def rows(num) do
    1..num
    |> Enum.reduce([], fn
      1, triangle -> [[1] | triangle]
      2, triangle -> [[1, 1] | triangle]
      n, triangle ->
        [last_row | _] = triangle
        coeffs = Enum.map(1..n-2, fn i ->
          Enum.slice(last_row, i-1..i) |> Enum.sum
        end)
        [[1] ++ coeffs ++ [1] | triangle]
    end)
    |> Enum.reverse
  end
end
