defmodule Queens do
  @type t :: %Queens{black: {integer, integer}, white: {integer, integer}}
  defstruct [:white, :black]

  @doc """
  Creates a new set of Queens
  """
  @spec new(Keyword.t()) :: Queens.t()
  def new(opts \\ []) do
    opts = Keyword.validate!(opts, black: {}, white: {})
    {black, white} = {opts[:black], opts[:white]}

    with true <- black != white,
         true <- match?({}, black) or
           (elem(black, 0) in 0..7 and elem(black, 1) in 0..7),
         true <- match?({}, white) or
           (elem(white, 0) in 0..7 and elem(white, 1) in 0..7)
    do
      %__MODULE__{black: black, white: white}
    else
      _ -> raise ArgumentError
    end
  end

  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(%__MODULE__{black: black, white: white}) do
    for r <- 0..7, c <- 0..7 do
      case {r, c} do
        ^black -> "B"
        ^white -> "W"
        _ -> "_"
      end
    end
    |> Stream.chunk_every(8)
    |> Stream.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%__MODULE__{white: {}}), do: false
  def can_attack?(%__MODULE__{black: {}}), do: false
  def can_attack?(%__MODULE__{black: {r, _}, white: {r, _}}), do: true
  def can_attack?(%__MODULE__{black: {_, c}, white: {_, c}}), do: true
  def can_attack?(%__MODULE__{black: {r1, c1}, white: {r2, c2}})
    when abs(r1 - r2) == abs(c1 - c2), do: true
  def can_attack?(_), do: false
end
