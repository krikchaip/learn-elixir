defmodule Matrix do
  defstruct rows: [], columns: []

  @doc """
  Convert an `input` string, with rows separated by newlines and values
  separated by single spaces, into a `Matrix` struct.
  """
  @spec from_string(input :: String.t()) :: %Matrix{}
  def from_string(input) do
    rows =
      String.split(input, "\n")
      |> Stream.map(&String.split/1)
      |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)
    columns = Enum.zip_with(rows, & &1)

    %Matrix{rows: rows, columns: columns}
  end

  @doc """
  Write the `matrix` out as a string, with rows separated by newlines and
  values separated by single spaces.
  """
  @spec to_string(matrix :: %Matrix{}) :: String.t()
  def to_string(%Matrix{rows: rows}) do
    rows |> Enum.map(&Enum.join(&1, " ")) |> Enum.join("\n")
  end

  @doc """
  Given a `matrix`, return its rows as a list of lists of integers.
  """
  @spec rows(matrix :: %Matrix{}) :: list(list(integer))
  def rows(%Matrix{rows: rows}) do
    rows
  end

  @doc """
  Given a `matrix` and `index`, return the row at `index`.
  """
  @spec row(matrix :: %Matrix{}, index :: integer) :: list(integer)
  def row(%Matrix{rows: rows}, index) do
    rows |> Enum.at(index - 1)
  end

  @doc """
  Given a `matrix`, return its columns as a list of lists of integers.
  """
  @spec columns(matrix :: %Matrix{}) :: list(list(integer))
  def columns(%Matrix{columns: columns}) do
    columns
  end

  @doc """
  Given a `matrix` and `index`, return the column at `index`.
  """
  @spec column(matrix :: %Matrix{}, index :: integer) :: list(integer)
  def column(%Matrix{columns: columns}, index) do
    columns |> Enum.at(index - 1)
  end
end
