defmodule CustomSet do
  @opaque t :: %__MODULE__{map: map}

  defstruct [:map]

  @spec new(Enum.t()) :: t
  def new(enumerable) do
    enumerable
    |> Enum.uniq()
    |> Map.new(&{&1, true})
    |> case do
      map when map != %{} -> %__MODULE__{map: map}
      _ -> %__MODULE__{}
    end
  end

  @spec empty?(t) :: boolean
  def empty?(%__MODULE__{map: map}), do: is_nil(map)

  @spec contains?(t, any) :: boolean
  def contains?(%__MODULE__{map: nil}, _), do: false
  def contains?(%__MODULE__{map: map}, element) do
    {element, true} in map
  end

  @spec subset?(t, t) :: boolean
  def subset?(%__MODULE__{map: nil}, _), do: true
  def subset?(_, %__MODULE__{map: nil}), do: false
  def subset?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Enum.all?(map1, & &1 in map2)
  end

  @spec disjoint?(t, t) :: boolean
  def disjoint?(%__MODULE__{map: nil}, _), do: true
  def disjoint?(_, %__MODULE__{map: nil}), do: true
  def disjoint?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Enum.all?(map1, & &1 not in map2)
  end

  @spec equal?(t, t) :: boolean
  def equal?(%__MODULE__{map: nil}, %__MODULE__{map: nil}), do: true
  def equal?(%__MODULE__{map: nil}, _), do: false
  def equal?(_, %__MODULE__{map: nil}), do: false
  def equal?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Enum.all?(map1, & &1 in map2) and Enum.all?(map2, & &1 in map1)
  end

  @spec add(t, any) :: t
  def add(%__MODULE__{map: nil}, element), do: new([element])
  def add(%__MODULE__{map: map} = custom_set, element) do
    map =
      if contains?(custom_set, element),
      do: map,
      else: put_in(map[element], true)

    %__MODULE__{map: map}
  end

  @spec intersection(t, t) :: t
  def intersection(
    %__MODULE__{map: map1} = set_a,
    %__MODULE__{map: map2} = set_b
  ) do
    cond do
      empty?(set_a) -> new([])
      empty?(set_b) -> new([])
      disjoint?(set_a, set_b) -> new([])
      subset?(set_a, set_b) -> set_a
      subset?(set_b, set_a) -> set_b
      true ->
        map1 = Enum.sort(map1)
        map2 = Enum.sort(map2)

        result =
          if length(map1) < length(map2),
          do: Enum.filter(map1, & &1 in map2),
          else: Enum.filter(map2, & &1 in map1)

        %__MODULE__{map: Map.new(result)}
    end
  end

  @spec difference(t, t) :: t
  def difference(%__MODULE__{map: nil} = empty, _), do: empty
  def difference(custom_set, %__MODULE__{map: nil}), do: custom_set
  def difference(%__MODULE__{map: map_a}, %__MODULE__{map: map_b}) do
    result = Enum.reject(map_a, & &1 in map_b)
    %__MODULE__{map: Map.new(result)}
  end

  @spec union(t, t) :: t
  def union(%__MODULE__{map: nil}, set_b), do: set_b
  def union(set_a, %__MODULE__{map: nil}), do: set_a
  def union(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Map.merge(map1, map2)
    |> Enum.uniq()
    |> Map.new()
    |> then(&%__MODULE__{map: &1})
  end
end
