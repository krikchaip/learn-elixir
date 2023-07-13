defmodule KV.Registry.Test do
  use ExUnit.Case

  setup do
    # ** ✅ recommended pattern to start process. It calls Module.start_link/1 underneath.
    # ** ExUnit will guarantee that the registry process will be shutdown before the next test starts.
    registry = start_supervised!(KV.Registry)

    %{registry: registry}
  end

  test "spawn buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    # ** async call
    KV.Registry.create(registry, "shopping")

    # ** assert pattern to match
    assert {:ok, _} = KV.Registry.lookup(registry, "shopping")
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    Agent.stop(bucket)

    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
