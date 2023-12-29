defmodule RailFenceCipher do
  @doc """
  Encode a given plaintext to the corresponding rail fence ciphertext
  """
  @spec encode(String.t(), pos_integer) :: String.t()
  def encode(str, 1), do: str

  def encode(str, rails) do
    groups = 2 * (rails - 1)

    str
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.group_by(fn
      {_, i} when rem(i, groups) > div(groups, 2) -> groups - rem(i, groups)
      {_, i} when rem(i, groups) <= div(groups, 2) -> rem(i, groups)
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join(fn
      {_, group} -> Enum.map(group, &elem(&1, 0))
    end)
  end

  @doc """
  Decode a given rail fence ciphertext to the corresponding plaintext
  """
  @spec decode(String.t(), pos_integer) :: String.t()
  def decode(str, 1), do: str
  def decode(str, rails) when byte_size(str) < rails, do: str

  def decode(str, rails) do
    total_len = String.length(str)

    rails
    |> build_empty_rails(total_len)
    |> fill_empty_rails(String.codepoints(str))
    |> read_zigzag({rails}, {0, total_len, &(&1 + 1)})
  end

  defp build_empty_rails(rails, total_len) do
    []
    |> List.duplicate(rails)
    |> Enum.with_index()
    |> build_zigzag({rails}, {0, total_len, &(&1 + 1)})
  end

  defp build_zigzag(groups, _, {_, 0, _}), do: groups

  defp build_zigzag(groups, {rails} = info, {curr, n, walker}) do
    target = [Access.at(curr), Access.elem(0)]

    walker =
      cond do
        curr == 0 -> &(&1 + 1)
        curr == rails - 1 -> &(&1 - 1)
        true -> walker
      end

    groups
    |> update_in(target, &[nil | &1])
    |> build_zigzag(info, {walker.(curr), n - 1, walker})
  end

  defp fill_empty_rails([], []), do: []

  defp fill_empty_rails([{group, i} | empty_rails], chars) do
    {group, chars} = Enum.split(chars, length(group))
    [{group, i} | fill_empty_rails(empty_rails, chars)]
  end

  defp read_zigzag(_, _, {_, 0, _}), do: ""

  defp read_zigzag(groups, {rails} = info, {curr, n, walker}) do
    target = [Access.at(curr), Access.elem(0)]
    {g, groups} = get_and_update_in(groups, target, &maybe_shift/1)

    walker =
      cond do
        curr == 0 -> &(&1 + 1)
        curr == rails - 1 -> &(&1 - 1)
        true -> walker
      end

    case g do
      [] -> read_zigzag(groups, info, {walker.(curr), n - 1, walker})
      _ -> hd(g) <> read_zigzag(groups, info, {walker.(curr), n - 1, walker})
    end
  end

  defp maybe_shift([]), do: {[], []}
  defp maybe_shift([_ | xs] = curr), do: {curr, xs}
end
