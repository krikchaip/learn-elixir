defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    inventory |> Enum.sort_by(& &1[:price])
  end

  def with_missing_price(inventory) do
    inventory |> Enum.filter(&is_nil(&1[:price]))
  end

  def update_names(inventory, old_word, new_word) do
    inventory |> Enum.map(&Map.put(&1, :name, String.replace(&1[:name], old_word, new_word)))
  end

  def increase_quantity(item, count) do
    quantity_by_size =
      Map.new(item[:quantity_by_size], fn
        {k, v} -> {k, v + count}
      end)

    Map.put(item, :quantity_by_size, quantity_by_size)
  end

  def total_quantity(item) do
    Enum.reduce(item[:quantity_by_size], 0, fn {_, v}, acc -> v + acc end)
  end
end
