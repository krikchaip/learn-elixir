defmodule Prime do
  @doc """
  Generates the nth prime.
  """
  @spec nth(non_neg_integer) :: non_neg_integer
  def nth(n) when n > 0 do
    2
    |> Stream.iterate(&(&1 + 1))
    |> Stream.filter(&is_prime/1)
    |> Enum.at(n - 1)
  end

  defp is_prime(2), do: true
  defp is_prime(3), do: true
  defp is_prime(n) when rem(n, 2) == 0 or rem(n, 3) == 0, do: false
  defp is_prime(n) do
    root_n = :math.sqrt(n)
    5..trunc(root_n)//6
    |> Enum.all?(&(rem(n, &1) != 0 and rem(n, &1 + 2) != 0))
  end
end
