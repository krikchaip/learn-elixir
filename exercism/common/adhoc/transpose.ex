defmodule Transpose do
  @doc """
  Given an input text, output it transposed.

  Rows become columns and columns become rows. See https://en.wikipedia.org/wiki/Transpose.

  If the input has rows of different lengths, this is to be solved as follows:
    * Pad to the left with spaces.
    * Don't pad to the right.

  ## Examples

    iex> Transpose.transpose("ABC\\nDE")
    "AD\\nBE\\nC"

    iex> Transpose.transpose("AB\\nDEF")
    "AD\\nBE\\n F"
  """

  @spec transpose(String.t()) :: String.t()
  def transpose(""), do: ""
  def transpose(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> fill_blanks()
    |> do_transpose()
  end

  defp fill_blanks(rows) do
    max_cols = rows |> Enum.max_by(&length/1) |> length()

    Enum.map(rows, fn
      r when length(r) < max_cols ->
        r ++ List.duplicate("", max_cols - length(r))
      r -> r
    end)
  end

  defp do_transpose(rows) do
    rows
    |> Enum.zip_with(&pad_leading/1)
    |> Enum.join("\n")
  end

  defp pad_leading(col) do
    {leading, rest} = Enum.split_while(col, & &1 == "")

    leading = String.duplicate(" ", length(leading))
    rest =
      rest
      |> Enum.reverse()
      |> Enum.drop_while(& &1 == "")
      |> Enum.map(&if &1 == "", do: " ", else: &1)
      |> Enum.reverse()
      |> Enum.join()

    leading <> rest
  end
end
