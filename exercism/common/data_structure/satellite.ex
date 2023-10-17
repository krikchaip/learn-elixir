defmodule Satellite do
  @typedoc """
  A tree, which can be empty, or made from a left branch, a node and a right branch
  """
  @type tree :: {} | {tree, any, tree}

  @doc """
  Build a tree from the elements given in a pre-order and in-order style
  """
  @spec build_tree(preorder :: [any], inorder :: [any]) :: {:ok, tree} | {:error, String.t()}
  def build_tree(preorder, inorder) do
    length? = length(preorder) == length(inorder)
    elements? = preorder -- inorder == []
    uniq? = Enum.all?([preorder, inorder], fn xs ->
      xs
      |> Enum.frequencies()
      |> Enum.filter(&elem(&1, 1) > 1)
      |> then(& &1 == [])
    end)

    with :ok <- validate(length?, "traversals must have the same length"),
        :ok <- validate(elements?, "traversals must have the same elements"),
        :ok <- validate(uniq?, "traversals must contain unique items") do
      {:ok, do_build_tree(preorder, inorder)}
    end
  end

  defp do_build_tree([], _), do: {}
  defp do_build_tree([e | preorder], inorder) do
    left = Enum.filter(preorder, &compare(inorder, &1, e) == :lt)
    right = Enum.filter(preorder, &compare(inorder, &1, e) == :gt)

    {do_build_tree(left, inorder), e, do_build_tree(right, inorder)}
  end

  defp validate(condition, message) do
    if(condition, do: :ok, else: {:error, message})
  end

  defp compare(ordering, a, b) do
    a = Enum.find_index(ordering, & &1 == a)
    b = Enum.find_index(ordering, & &1 == b)

    cond do
      a > b -> :gt
      a < b -> :lt
      true -> :eq
    end
  end
end
