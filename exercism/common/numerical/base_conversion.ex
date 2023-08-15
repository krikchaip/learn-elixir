defmodule AllYourBase do
  @doc """
  Given a number in input base, represented as a sequence of digits, converts it to output base,
  or returns an error tuple if either of the bases are less than 2
  """
  @spec convert(list, integer, integer) :: {:ok, list} | {:error, String.t()}
  def convert(_, _, output_base) when output_base < 2, do: {:error, "output base must be >= 2"}
  def convert(_, input_base, _) when input_base < 2, do: {:error, "input base must be >= 2"}
  def convert([], _, _), do: {:ok, [0]}
  def convert(digits, input_base, output_base) do
    with false <- Enum.any?(digits, & &1 not in 0..input_base-1) do
      exponents = Enum.map(length(digits)-1..0, & input_base ** &1)
      base_10 =
        digits
        |> Enum.zip_with(exponents, & &1*&2)
        |> Enum.sum

      result =
        base_10
        |> Stream.unfold(fn
          0 -> nil
          n -> {rem(n, output_base), div(n, output_base)}
        end)
        |> Enum.reverse

      result = if result == [], do: [0], else: result
      {:ok, result}
    else
      _ -> {:error, "all digits must be >= 0 and < input base"}
    end
  end
end
