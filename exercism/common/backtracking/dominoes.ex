defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino]) :: boolean
  def chain?([]), do: true
  def chain?([{a, b}]), do: a == b
  def chain?([{l, r} | rest]) do
    Enum.any?(rest, fn
      {^r, x} = d -> chain?([{l, x} | List.delete(rest, d)])
      {x, ^r} = d -> chain?([{l, x} | List.delete(rest, d)])
      _ -> false
    end)
  end
end
