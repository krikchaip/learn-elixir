defmodule Rectangles do
  @doc """
  Count the number of ASCII rectangles.
  """
  @spec count(input :: String.t()) :: integer()
  def count(input) do
    grid = parse_grid(input)

    for top_left <- Enum.filter(get_table(grid), &(get_val(&1) == ?+)),
        bottom_right <- find_bottom_right(grid, top_left),
        form_rectangle?(grid, top_left, bottom_right),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  defp parse_grid(str) do
    lines =
      str
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    table =
      for {line, row} <- Enum.with_index(lines),
          {val, col} <- Enum.with_index(line),
          val != ?\s,
          into: %{} do
        {{row, col}, val}
      end

    dimension =
      case length(lines) do
        l when l > 0 -> {l, length(hd(lines))}
        _ -> {0, 0}
      end

    {table, dimension}
  end

  defp find_bottom_right(grid, node) do
    table = get_table(grid)
    dimension = get_dimension(grid)

    for i <- (get_row(node) + 1)..(get_rows(dimension) - 1),
        j <- (get_col(node) + 1)..(get_cols(dimension) - 1),
        i > get_row(node),
        j > get_col(node),
        bottom_right = {{i, j}, table[{i, j}]},
        get_val(bottom_right) == ?+ do
      bottom_right
    end
  end

  defp form_rectangle?(grid, top_left, bottom_right) do
    table = get_table(grid)

    bottom_left = {get_row(bottom_right), get_col(top_left)}
    bottom_left = {bottom_left, table[bottom_left]}

    top_right = {get_row(top_left), get_col(bottom_right)}
    top_right = {top_right, table[top_right]}

    with true <- get_val(top_right) == ?+,
         true <- get_val(bottom_left) == ?+,
         true <- Enum.all?(find_val_from(grid, top_left, top_right), &(&1 in ~c"+-")),
         true <- Enum.all?(find_val_from(grid, bottom_left, bottom_right), &(&1 in ~c"+-")),
         true <- Enum.all?(find_val_from(grid, top_left, bottom_left), &(&1 in ~c"+|")),
         true <- Enum.all?(find_val_from(grid, top_right, bottom_right), &(&1 in ~c"+|")) do
      :ok
    end
  end

  defp find_val_from(grid, node_a, node_b) do
    table = get_table(grid)

    for i <- get_row(node_a)..get_row(node_b),
        j <- get_col(node_a)..get_col(node_b),
        val <- [table[{i, j}]] do
      val
    end
  end

  defp get_table({table, _}), do: table
  defp get_dimension({_, dimension}), do: dimension

  defp get_row({{row, _}, _}), do: row
  defp get_col({{_, col}, _}), do: col
  defp get_val({_, val}), do: val

  defp get_rows({rows, _}), do: rows
  defp get_cols({_, cols}), do: cols
end
