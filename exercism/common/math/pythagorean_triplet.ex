# references:
#   - https://www.geeksforgeeks.org/pythagorean-triplet-given-sum
#   - https://exercism.org/tracks/elixir/exercises/pythagorean-triplet/solutions/duien
#   - https://exercism.org/tracks/elixir/exercises/pythagorean-triplet/solutions/georgevanuta
defmodule Triplet do
  @doc """
  Calculates sum of a given triplet of integers.
  """
  @spec sum([non_neg_integer]) :: non_neg_integer
  def sum(triplet) do
    Enum.sum(triplet)
  end

  @doc """
  Calculates product of a given triplet of integers.
  """
  @spec product([non_neg_integer]) :: non_neg_integer
  def product(triplet) do
    Enum.product(triplet)
  end

  @doc """
  Determines if a given triplet is pythagorean. That is, do the squares of a and b add up to the square of c?
  """
  @spec pythagorean?([non_neg_integer]) :: boolean
  def pythagorean?([a, b, c]) do
    c ** 2 == a ** 2 + b ** 2
  end

  @doc """
  Generates a list of pythagorean triplets whose values add up to a given sum.
  """
  @spec generate(non_neg_integer) :: [list(non_neg_integer)]
  def generate(s) do
    for a <- 1..div(s, 3),
        b <- (a + 1)..(s - a),
        c = s - a - b,
        pythagorean?([a, b, c]),
        sum([a, b, c]) == s do
      [a, b, c]
    end
  end
end
