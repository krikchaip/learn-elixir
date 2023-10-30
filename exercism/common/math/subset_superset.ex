defmodule Sublist do
  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """
  def compare(a, b) do
    cond do
      a == b -> :equal
      contains?(a, b) -> :superlist
      contains?(b, a) -> :sublist
      true -> :unequal
    end
  end

  defp contains?([], _), do: false
  defp contains?(a, b) do
    if List.starts_with?(a, b), do: true, else: contains?(tl(a), b)
  end
end
