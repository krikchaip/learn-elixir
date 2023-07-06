defmodule KV do
  def init(map \\ %{}) when is_map(map) do
    pid = spawn_link(fn -> loop(map) end)

    # give `pid` a name, and allowing everyone that knows the name to send a message
    Process.register(pid, :kv)

    :ok
  end

  def get(key) do
    send :kv, [self(), {:get, key}]
    receive do
      {:ok, value} -> value
    end
  end

  def set(key, value) do
    send :kv, [self(), {:set, key, value}]
    receive do
      {:ok} -> {:ok, key, value}
    end
  end

  defp loop(map) do
    receive do
      [caller, {:get, key}] ->
        send caller, {:ok, map[key]}
        loop map
      [caller, {:set, key, value}] ->
        map = Map.put(map, key, value)
        send caller, {:ok}
        loop map
    end
  end
end

# KV.init
# KV.set("winner", 27) |> inspect
# KV.get("winner") |> inspect
