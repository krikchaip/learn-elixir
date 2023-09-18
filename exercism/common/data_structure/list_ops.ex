defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  def count([]), do: 0
  def count([_ | l]), do: 1 + count(l)

  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])
  defp reverse([], xs), do: xs
  defp reverse([x | l], xs), do: reverse(l, [x | xs])

  @spec map(list, (any -> any)) :: list
  def map([], _), do: []
  def map([x | l], f), do: [f.(x) | map(l, f)]

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter([], _), do: []
  def filter([x | l], f), do: if(f.(x), do: [x | filter(l, f)], else: filter(l, f))

  @type acc :: any
  @spec foldl(list, acc, (any, acc -> acc)) :: acc
  def foldl([], acc, _), do: acc
  def foldl([x | l], acc, f), do: foldl(l, f.(x, acc), f)

  @spec foldr(list, acc, (any, acc -> acc)) :: acc
  def foldr(l, acc, f), do: foldl(reverse(l), acc, f)

  @spec append(list, list) :: list
  def append([], b), do: b
  def append([x | a], b), do: [x | append(a, b)]

  @spec concat([[any]]) :: [any]
  def concat([]), do: []
  def concat([l | ll]), do: append(l, concat(ll))
end
