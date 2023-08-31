# ref1: https://gocardless.com/guides/posts/what-is-luhn-algorithm/
# ref2: https://www.geeksforgeeks.org/luhn-algorithm/
defmodule Luhn do
  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean
  def valid?(number) do
    cond do
      String.length(number) <= 1 or
      number =~ ~r/[^0-9 ]/ ->
        false
      true ->
        [x | digits] =
          number
          |> String.split(" ", trim: true)
          |> Enum.map(&String.codepoints/1)
          |> Enum.flat_map(fn xs -> Enum.map(xs, &String.to_integer/1) end)
          |> Enum.reverse

        cond do
          x == 0 and length(digits) == 0 -> false
          true ->
            digits
            |> Enum.map_every(2, fn
              x when x * 2 > 9 -> x * 2 - 9
              x -> x * 2
            end)
            |> Enum.sum
            |> then(&rem(&1 + x, 10) == 0)
        end
    end
  end
end
