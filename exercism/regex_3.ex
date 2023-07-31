defmodule RunLengthEncoder do
  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "AABBBCCCC" => "2A3B4C"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "2A3B4C" => "AABBBCCCC"
  """
  @spec encode(String.t()) :: String.t()
  def encode(string) do
    ~r/([A-Za-z ])\1*/
    |> Regex.scan(string)
    |> Enum.map(fn [repeated, char] ->
      len = String.length(repeated)
      if len > 1, do: "#{len}#{char}", else: char
    end)
    |> Enum.join
  end

  @spec decode(String.t()) :: String.t()
  def decode(string) do
    ~r/(\d+)([A-Za-z ])|[A-Za-z ]/
    |> Regex.scan(string)
    |> Enum.map(fn
      [_, count, char] ->
        count = String.to_integer(count)
        String.duplicate char, count
      [char] -> char
    end)
    |> Enum.join
  end
end
