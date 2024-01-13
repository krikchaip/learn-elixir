defmodule Say do
  @dict %{
    0 => "zero",
    1 => "one",
    2 => "two",
    3 => "three",
    4 => "four",
    5 => "five",
    6 => "six",
    7 => "seven",
    8 => "eight",
    9 => "nine",
    10 => "ten",
    11 => "eleven",
    12 => "twelve",
    13 => "thirteen",
    14 => "fourteen",
    15 => "fifteen",
    16 => "sixteen",
    17 => "seventeen",
    18 => "eighteen",
    19 => "nineteen",
    20 => "twenty",
    30 => "thirty",
    40 => "forty",
    50 => "fifty",
    60 => "sixty",
    70 => "seventy",
    80 => "eighty",
    90 => "ninety"
  }

  @suffixes %{
    1_000 => "thousand",
    1_000_000 => "million",
    1_000_000_000 => "billion"
  }

  @doc """
  Translate a positive integer into English.
  """
  @spec in_english(integer) :: {atom, String.t()}
  def in_english(n) when n < 0 or n > 999_999_999_999,
    do: {:error, "number is out of range"}

  def in_english(n) when is_map_key(@dict, n),
    do: {:ok, @dict[n]}

  def in_english(n) when n < 100 do
    [tens, ones] = Integer.digits(n)
    {:ok, tens} = in_english(tens * 10)
    {:ok, ones} = in_english(ones)

    if ones == "zero", do: {:ok, tens}, else: {:ok, "#{tens}-#{ones}"}
  end

  def in_english(n) when n < 1_000 do
    [hundreds | tens] = Integer.digits(n)
    {:ok, hundreds} = in_english(hundreds)
    {:ok, tens} = in_english(Integer.undigits(tens))

    if tens == "zero" do
      {:ok, "#{hundreds} hundred"}
    else
      {:ok, "#{hundreds} hundred #{tens}"}
    end
  end

  def in_english(n) do
    digit_groups =
      n
      |> Integer.digits()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.reverse()
      |> Enum.map(&Enum.reverse/1)

    {_, result} =
      for group <- digit_groups,
          group = Integer.undigits(group),
          reduce: {digit_groups, ""} do
        {[_ | rest], acc} when group == 0 ->
          {rest, acc}

        {[_ | rest], acc} ->
          remaining_digits = Enum.map(rest, &length/1) |> Enum.sum()
          suffix = @suffixes[10 ** remaining_digits]
          {:ok, hundreds} = in_english(group)
          {rest, acc <> " #{hundreds} #{suffix}"}
      end

    {:ok, String.trim(result)}
  end
end
