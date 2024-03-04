defmodule TwoBucket do
  defstruct [:bucket_one, :bucket_two, :moves]

  @type t :: %TwoBucket{
    bucket_one: integer,
    bucket_two: integer,
    moves: integer
  }

  defp new(), do: %__MODULE__{bucket_one: 0, bucket_two: 0, moves: 0}

  @doc """
  Find the quickest way to fill a bucket with some amount of water from two buckets of specific sizes.
  """
  @spec measure(integer, integer, integer, :one | :two) :: {:ok, TwoBucket.t()} | {:error, :impossible}
  def measure(size_one, size_two, goal, start_bucket) do
    meta = %{
      size_one: size_one,
      size_two: size_two,
      goal: goal,
      start_bucket: start_bucket
    }

    possible_actions = %{
      {:pour, :one} => fn two_bucket -> pouring(meta, two_bucket, :one, :two) end,
      {:pour, :two} => fn two_bucket -> pouring(meta, two_bucket, :two, :one) end,
      {:empty, :one} => fn two_bucket -> emptying(two_bucket, :one) end,
      {:empty, :two} => fn two_bucket -> emptying(two_bucket, :two) end,
      {:fill, :one} => fn two_bucket -> filling(meta, two_bucket, :one) end,
      {:fill, :two} => fn two_bucket -> filling(meta, two_bucket, :two) end
    }

    two_bucket = possible_actions[{:fill, start_bucket}].(new())
    actions = Enum.map(possible_actions, &elem(&1, 1))
    visited = MapSet.new([Map.delete(two_bucket, :moves)])

    start(meta, two_bucket, actions, visited) || {:error, :impossible}
  end

  defp pouring(meta, %__MODULE__{bucket_one: b1, bucket_two: b2, moves: m}, :one, :two) when b1 + b2 > meta.size_two do
    %__MODULE__{bucket_one: b1 + b2 - meta.size_two, bucket_two: meta.size_two, moves: m + 1}
  end
  defp pouring(_meta, %__MODULE__{bucket_one: b1, bucket_two: b2, moves: m}, :one, :two) do
    %__MODULE__{bucket_one: 0, bucket_two: b1 + b2, moves: m + 1}
  end

  defp pouring(meta, %__MODULE__{bucket_one: b1, bucket_two: b2, moves: m}, :two, :one) when b1 + b2 > meta.size_one do
    %__MODULE__{bucket_one: meta.size_one, bucket_two: b1 + b2 - meta.size_one, moves: m + 1}
  end
  defp pouring(_meta, %__MODULE__{bucket_one: b1, bucket_two: b2, moves: m}, :two, :one) do
    %__MODULE__{bucket_one: b1 + b2, bucket_two: 0, moves: m + 1}
  end

  defp emptying(two_bucket, :one), do: emptying(put_in(two_bucket.bucket_one, 0))
  defp emptying(two_bucket, :two), do: emptying(put_in(two_bucket.bucket_two, 0))
  defp emptying(two_bucket), do: update_in(two_bucket.moves, & &1 + 1)

  defp filling(meta, two_bucket, :one), do: filling(meta, put_in(two_bucket.bucket_one, meta.size_one))
  defp filling(meta, two_bucket, :two), do: filling(meta, put_in(two_bucket.bucket_two, meta.size_two))
  defp filling(_meta, two_bucket), do: update_in(two_bucket.moves, & &1 + 1)

  defp start(meta, %__MODULE__{bucket_one: b1} = two_bucket, _actions, _visited) when b1 == meta.goal, do: {:ok, two_bucket}
  defp start(meta, %__MODULE__{bucket_two: b2} = two_bucket, _actions, _visited) when b2 == meta.goal, do: {:ok, two_bucket}

  defp start(meta, two_bucket, actions, visited) do
    Enum.find_value(actions, fn action ->
      with new_two_bucket <- action.(two_bucket),
           true <- rulecheck(meta, new_two_bucket),
           node when not is_nil(node) <- continue(new_two_bucket, visited) do
        start(meta, new_two_bucket, actions, MapSet.put(visited, node))
      end
    end)
  end

  defp rulecheck(%{start_bucket: :one, size_two: b2}, %__MODULE__{bucket_one: 0, bucket_two: b2}), do: false
  defp rulecheck(%{start_bucket: :two, size_one: b1}, %__MODULE__{bucket_one: b1, bucket_two: 0}), do: false
  defp rulecheck(_meta, _two_bucket), do: true
  
  defp continue(two_bucket, visited) do
    node = Map.delete(two_bucket, :moves)
    if node in visited, do: nil, else: node
  end
end