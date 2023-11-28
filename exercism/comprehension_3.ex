defmodule Minesweeper do
  @doc """
  Annotate empty spots next to mines with the number of mines next to them.
  """
  @spec annotate([String.t()]) :: [String.t()]
  def annotate(board) do
    for {row, i} <- Enum.with_index(board) do
      for {col, j} <- Enum.with_index(String.codepoints(row)), into: "" do
        board
        |> count_mines(col, {i, j})
        |> to_string()
      end
    end
  end

  defp count_mines(_, "*", _), do: "*"

  defp count_mines(board, " ", {i, j}) do
    [
      {i - 1, j - 1},
      {i - 1, j},
      {i - 1, j + 1},
      {i, j - 1},
      {i, j + 1},
      {i + 1, j - 1},
      {i + 1, j},
      {i + 1, j + 1}
    ]
    |> Enum.count(fn
      {r, c} when r < 0 or c < 0 -> false
      {r, c} -> has_mine?(board, {r, c})
    end)
    |> then(&if &1 == 0, do: " ", else: &1)
  end

  defp has_mine?(board, {r, c}) do
    with row when row != nil <- Enum.at(board, r),
         col when col != nil <- String.at(row, c) do
      col == "*"
    end
  end
end
