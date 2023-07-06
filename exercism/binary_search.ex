defmodule BinarySearch do
  def search({}, _), do: :not_found
  def search(numbers, key), do: search(numbers, key, 0, tuple_size(numbers))
  def search(_, _, l, r) when l == r, do: :not_found
  def search(numbers, key, l, r) do
    m = div(r - l, 2) + l
    v = elem(numbers, m)
    cond do
      key == v -> {:ok, m}
      key < v -> search(numbers, key, l, m)
      key > v -> search(numbers, key, m + 1, r)
    end
  end
end
