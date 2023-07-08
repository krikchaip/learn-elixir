defmodule KitchenCalculator do
  def get_volume({_, v}), do: v

  def to_milliliter({:milliliter, v}), do: {:milliliter, v}
  def to_milliliter({:cup, v}), do: {:milliliter, v * 240}
  def to_milliliter({:fluid_ounce, v}), do: {:milliliter, v * 30}
  def to_milliliter({:teaspoon, v}), do: {:milliliter, v * 5}
  def to_milliliter({:tablespoon, v}), do: {:milliliter, v * 15}

  def from_milliliter(p = {:milliliter, _}, u = :milliliter), do: p
  def from_milliliter(p = {:milliliter, v}, u = :cup), do: {u, v / 240}
  def from_milliliter(p = {:milliliter, v}, u = :fluid_ounce), do: {u, v / 30}
  def from_milliliter(p = {:milliliter, v}, u = :teaspoon), do: {u, v / 5}
  def from_milliliter(p = {:milliliter, v}, u = :tablespoon), do: {u, v / 15}

  def convert(volume_pair, unit), do:
    volume_pair
      |> to_milliliter
      |> from_milliliter(unit)
end
