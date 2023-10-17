defmodule BinarySearch do
  def search({}, _), do: :not_found
  def search(numbers, key), do: do_search(numbers, key, 0, tuple_size(numbers))

  def do_search(_, _, x, x), do: :not_found
  def do_search(numbers, key, l, r) do
    m = div(r - l, 2) + l
    v = elem(numbers, m)
    cond do
      key == v -> {:ok, m}
      key < v -> do_search(numbers, key, l, m)
      key > v -> do_search(numbers, key, m + 1, r)
    end
  end
end
