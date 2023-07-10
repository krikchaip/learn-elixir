defmodule RPG do
  defmodule Character do
    defstruct health: 100, mana: 0
  end

  defmodule LoafOfBread do
    defstruct []
  end

  defmodule ManaPotion do
    defstruct strength: 10
  end

  defmodule Poison do
    defstruct []
  end

  defmodule EmptyBottle do
    defstruct []
  end

  defprotocol Edible do
    @spec eat(
            item :: struct,
            char :: struct
          ) :: {struct | nil, struct}
    def eat(item, char)
  end

  defimpl Edible, for: LoafOfBread do
    def eat(_, char) do
      {nil, Map.update!(char, :health, &(&1 + 5))}
    end
  end

  defimpl Edible, for: ManaPotion do
    def eat(%ManaPotion{strength: mana}, char) do
      {%EmptyBottle{}, Map.update!(char, :mana, &(&1 + mana))}
    end
  end

  defimpl Edible, for: Poison do
    def eat(_, char) do
      {%EmptyBottle{}, Map.put(char, :health, 0)}
    end
  end
end
