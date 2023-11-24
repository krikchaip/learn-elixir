defmodule PalindromeProducts do
  @doc """
  Generates all palindrome products from an optionally given min factor (or 1) to a given max factor.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: map
  def generate(max_factor, min_factor \\ 1)

  def generate(max_factor, min_factor) when min_factor > max_factor do
    raise ArgumentError
  end

  def generate(max_factor, min_factor) do
    for i <- min_factor..max_factor,
        j <- i..max_factor,
        ij = i * j,
        palindrome?(i * j),
        reduce: %{} do
      %{^ij => _} = acc -> Map.update!(acc, i * j, &[[i, j] | &1])
      acc -> Map.put(acc, i * j, [[i, j]])
    end
  end

  defp palindrome?(n) do
    digits = Integer.digits(n)
    digits == Enum.reverse(digits)
  end
end
