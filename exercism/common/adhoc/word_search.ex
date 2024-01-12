defmodule WordSearch do
  defmodule Location do
    defstruct [:from, :to]

    @type t :: %Location{
            from: %{row: integer, column: integer},
            to: %{row: integer, column: integer}
          }
  end

  @vector [
    # top
    {-1, 0},
    # bottom
    {1, 0},
    # left
    {0, -1},
    # right
    {0, 1},
    # top left
    {-1, -1},
    # top right
    {-1, 1},
    # bottom left
    {1, -1},
    # bottom right
    {1, 1}
  ]

  @doc """
  Find the start and end positions of words in a grid of letters.
  Row and column positions are 1 indexed.
  """
  @spec search(String.t(), [String.t()]) :: %{String.t() => nil | Location.t()}
  def search(grid, words) do
    max_length = String.length(Enum.max_by(words, &String.length/1))
    words_set = MapSet.new(words)
    answer = Enum.into(words, %{}, &{&1, nil})

    table = parse_table(grid)

    for from <- each_position(table.rows, table.cols),
        v <- @vector,
        result = find_word(words_set, table, from, v, max_length),
        result.word in words_set,
        into: answer do
      {result.word, %Location{from: from, to: result.to}}
    end
  end

  defp parse_table(grid) do
    t =
      for {line, i} <- Enum.with_index(String.split(grid)),
          {char, j} <- Enum.with_index(String.to_charlist(line)),
          into: %{} do
        {{i, j}, char}
      end

    {{max_i, max_j}, _} = Enum.max(t)

    %{t: t, rows: max_i + 1, cols: max_j + 1}
  end

  defp char_at(table, coord), do: table.t[{coord.row - 1, coord.column - 1}]

  defp each_position(rows, cols) do
    for r <- 1..rows,
        c <- 1..cols,
        do: %{row: r, column: c}
  end

  defp find_word(words_set, table, start, direction, max_length) do
    {dr, dc} = direction

    start
    |> Stream.iterate(&%{row: &1.row + dr, column: &1.column + dc})
    |> Enum.take(max_length)
    |> Enum.take_while(&char_at(table, &1))
    |> Enum.reduce_while(%{word: "", to: nil}, fn c, acc ->
      word = acc.word <> <<char_at(table, c)>>

      if word in words_set,
        do: {:halt, %{word: word, to: c}},
        else: {:cont, %{word: word, to: nil}}
    end)
  end
end
