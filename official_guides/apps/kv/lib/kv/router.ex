defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  @spec route(String.t(), module(), atom(), list(term())) :: term()
  def route(bucket, mod, fun, args) do
    c = String.first(bucket) |> to_charlist() |> hd

    entry =
      Enum.find(table(), fn {range, _} ->
        c in range
      end) || no_entry_error(bucket)

    node_name = elem(entry, 1)

    # ** If the entry node is the current node, apply as-is
    if node_name == node() do
      apply(mod, fun, args)
    else
      # ** Otherwise, apply it on the other node
      {KV.RouterTasks, node_name}
      |> Task.Supervisor.async(mod, fun, args)
      |> Task.await()
    end
  end

  # ** will raise an exception when an entry is out of range.
  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect(bucket)} in table #{inspect(table())}"
  end

  @doc ~S"""
  The routing table (replace \<computer-name\> with your local machine name).

  ### Example
  ```
  [
    {?a..?m, :"a@Krikchais-MacBook-Pro-M1"},
    {?n..?z, :"b@Krikchais-MacBook-Pro-M1"}
  ]
  ```
  """
  def table() do
    Application.fetch_env!(:kv, :routing_table)
  end
end
