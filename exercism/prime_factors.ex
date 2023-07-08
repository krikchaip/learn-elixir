# ref: https://www.geeksforgeeks.org/print-all-prime-factors-of-a-given-number/
defmodule PrimeFactors do
  @doc """
  Compute the prime factors for 'number'.

  The prime factors are prime numbers that when multiplied give the desired
  number.

  The prime factors of 'number' will be ordered lowest to highest.
  """
  @spec factors_for(pos_integer) :: [pos_integer]
  def factors_for(n), do: do_factors_for(n, [])

  defp do_factors_for(1, acc), do: acc
  defp do_factors_for(n, acc) when rem(n, 2) == 0 do
    do_factors_for div(n, 2), (acc ++ [2])
  end
  defp do_factors_for(n , acc) do
    factors_for_odd(n, acc, 3)
  end

  defp factors_for_odd(1, acc, _), do: acc
  defp factors_for_odd(n, acc, factor) when rem(n, factor) == 0 do
    factors_for_odd div(n, factor), (acc ++ [factor]), factor
  end
  defp factors_for_odd(n, acc, factor) do
    factors_for_odd(n, acc, factor + 2) # factor is now odd. so, +2 to skip even numbers
  end
end
