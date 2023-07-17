defmodule KV.Registry.Test do
  use ExUnit.Case

  setup do
    # ** ✅ recommended pattern to start process in isolation. It calls Module.start_link/1 underneath.
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
    {:ok, shopping} = KV.Registry.lookup(registry, "shopping")

    # ** sending :normal exit reason -> {:DOWN, ref, ...}
    Agent.stop(shopping)

    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, shopping} = KV.Registry.lookup(registry, "shopping")

    # ** sending :shutdown exit reason -> {:EXIT, ref, ...}
    Agent.stop(shopping, :shutdown)

    # ** PS. all linked processes receive an EXIT signal,
    # ** causing the linked process to also terminate unless it is trapping exits

    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
