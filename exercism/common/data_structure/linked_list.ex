defmodule LinkedList do
  @opaque t :: {any, t}

  @doc """
  Construct a new LinkedList
  """
  @spec new() :: t
  def new(), do: {:head, nil}

  @doc """
  Push an item onto a LinkedList
  """
  @spec push(t, any()) :: t
  def push({:head, t}, elem), do: {:head, {elem, t}}

  @doc """
  Counts the number of elements in a LinkedList
  """
  @spec count(t) :: non_neg_integer()
  def count({:head, nil}), do: 0
  def count({:head, t}), do: count(t)
  def count({_, nil}), do: 1
  def count({_, t}), do: 1 + count(t)

  @doc """
  Determine if a LinkedList is empty
  """
  @spec empty?(t) :: boolean()
  def empty?(t), do: match?({:head, nil}, t)

  @doc """
  Get the value of a head of the LinkedList
  """
  @spec peek(t) :: {:ok, any()} | {:error, :empty_list}
  def peek({:head, nil}), do: {:error, :empty_list}
  def peek({:head, {elem, _}}), do: {:ok, elem}

  @doc """
  Get tail of a LinkedList
  """
  @spec tail(t) :: {:ok, t} | {:error, :empty_list}
  def tail({:head, nil}), do: {:error, :empty_list}
  def tail({:head, {_, t}}), do: {:ok, {:head, t}}

  @doc """
  Remove the head from a LinkedList
  """
  @spec pop(t) :: {:ok, any(), t} | {:error, :empty_list}
  def pop({:head, nil}), do: {:error, :empty_list}
  def pop(t) do
    {:ok, elem} = peek(t)
    {:ok, t} = tail(t)
    {:ok, elem, t}
  end

  @doc """
  Construct a LinkedList from a stdlib List
  """
  @spec from_list(list()) :: t
  def from_list(list) do
    for elem <- list, reduce: new() do
      t -> push(t, elem)
    end
    |> reverse
  end

  @doc """
  Construct a stdlib List LinkedList from a LinkedList
  """
  @spec to_list(t) :: list()
  def to_list(t) do
    Stream.unfold(t, fn t ->
      case pop(t) do
        {:ok, elem, t} -> {elem, t}
        {:error, _} -> nil
      end
    end)
    |> Enum.to_list
  end

  @doc """
  Reverse a LinkedList
  """
  @spec reverse(t) :: t
  def reverse({:head, nil} = t), do: t
  def reverse(t), do: do_reverse(t, new())

  defp do_reverse(t1, t2) do
    case pop(t1) do
      {:ok, elem, t} -> do_reverse(t, push(t2, elem))
      {:error, _} -> t2
    end
  end
end
