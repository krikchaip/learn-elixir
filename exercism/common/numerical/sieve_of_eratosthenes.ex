defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) when limit < 2, do: []
  def primes_to(limit), do: primes_to(2, 2..limit)

  defp primes_to(prime, xs) do
    case Enum.reject(xs, &rem(&1, prime) == 0) do
      [] -> [prime]
      sieved -> [prime | primes_to(hd(sieved), sieved)]
    end
  end
end
