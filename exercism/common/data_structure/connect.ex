# This one is a graph exercise (utilizing :digraph module from Erlang)
defmodule Connect do
  @doc """
  Calculates the winner (if any) of a board
  using "O" as the white player
  and "X" as the black player
  """
  @spec result_for([String.t()]) :: :none | :white | :black
  def result_for(board) do
    graph =
      board
      |> remove_spaces()
      |> Enum.map(&String.codepoints/1)
      |> build_graph()

    cond do
      :digraph.get_path(graph, :top, :bottom) -> :white
      :digraph.get_path(graph, :left, :right) -> :black
      true -> :none
    end
  end

  defp remove_spaces(rows) do
    Enum.map(rows, &String.replace(&1, " ", ""))
  end

  @stone %{"O" => :white, "X" => :black}

  defp build_graph(board) do
    graph = new_graph()

    vertices =
      for {row, i} <- Enum.with_index(board),
          {v, j} <- Enum.with_index(row),
          color = @stone[v] do
        :digraph.add_vertex(graph, {color, i, j})
      end

    max_i = length(board) - 1
    max_j = length(Enum.at(board, 0)) - 1

    graph
    |> connect_terminals(vertices, {max_i, max_j})
    |> connect_vertices(vertices)
  end

  defp new_graph() do
    graph = :digraph.new()

    :digraph.add_vertex(graph, :top)
    :digraph.add_vertex(graph, :bottom)
    :digraph.add_vertex(graph, :left)
    :digraph.add_vertex(graph, :right)

    graph
  end

  defp connect_terminals(graph, [], _), do: graph

  defp connect_terminals(graph, [{:white, 0, _} = v | vertices], {0, _} = limit) do
    :digraph.add_edge(graph, :top, v)
    :digraph.add_edge(graph, v, :bottom)

    connect_terminals(graph, vertices, limit)
  end

  defp connect_terminals(graph, [{:white, 0, _} = v | vertices], limit) do
    :digraph.add_edge(graph, :top, v)
    connect_terminals(graph, vertices, limit)
  end

  defp connect_terminals(graph, [{:white, max_i, _} = v | vertices], {max_i, _} = limit) do
    :digraph.add_edge(graph, v, :bottom)
    connect_terminals(graph, vertices, limit)
  end

  defp connect_terminals(graph, [{:black, _, 0} = v | vertices], {_, 0} = limit) do
    :digraph.add_edge(graph, :left, v)
    :digraph.add_edge(graph, v, :right)

    connect_terminals(graph, vertices, limit)
  end

  defp connect_terminals(graph, [{:black, _, 0} = v | vertices], limit) do
    :digraph.add_edge(graph, :left, v)
    connect_terminals(graph, vertices, limit)
  end

  defp connect_terminals(graph, [{:black, _, max_j} = v | vertices], {_, max_j} = limit) do
    :digraph.add_edge(graph, v, :right)
    connect_terminals(graph, vertices, limit)
  end

  defp connect_terminals(graph, [_ | vertices], limit) do
    connect_terminals(graph, vertices, limit)
  end

  defp connect_vertices(graph, []), do: graph

  defp connect_vertices(graph, [{:white, i, j} = v | vertices]) do
    neighbours = [
      {:white, i - 1, j},
      {:white, i - 1, j + 1},
      {:white, i, j - 1},
      {:white, i, j + 1},
      {:white, i + 1, j},
      {:white, i + 1, j - 1}
    ]

    Enum.each(neighbours, fn w ->
      if w in vertices do
        :digraph.add_edge(graph, v, w)
        :digraph.add_edge(graph, w, v)
      end
    end)

    connect_vertices(graph, vertices)
  end

  defp connect_vertices(graph, [{:black, i, j} = v | vertices]) do
    neighbours = [
      {:black, i, j - 1},
      {:black, i + 1, j - 1},
      {:black, i - 1, j},
      {:black, i + 1, j},
      {:black, i, j + 1},
      {:black, i - 1, j + 1}
    ]

    Enum.each(neighbours, fn w ->
      if w in vertices do
        :digraph.add_edge(graph, v, w)
        :digraph.add_edge(graph, w, v)
      end
    end)

    connect_vertices(graph, vertices)
  end
end
