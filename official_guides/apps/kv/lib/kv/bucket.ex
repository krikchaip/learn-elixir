defmodule KV.Bucket do
  # ** will define a child_spec/1 function,
  # ** so your module can be used as a child in a supervision tree.
  use Agent, restart: :temporary

  # ** It is a convention to define a start_link/1 function
  # ** that always accepts a list of options
  @spec start_link(keyword()) :: Agent.agent()
  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end)
  end

  @spec get(Agent.agent(), any()) :: any()
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @spec put(Agent.agent(), any(), any()) :: :ok
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @spec delete(Agent.agent(), any()) :: any()
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
