defmodule KV.ETSRegistry.Test do
  use ExUnit.Case

  setup context do
    # ** each test requires different ETS table
    # ** so we use test name as table name to remain isolation
    start_supervised!({KV.ETSRegistry, name: context.test})

    %{registry: context.test}
  end

  test "spawn buckets", %{registry: registry} do
    assert KV.ETSRegistry.lookup(registry, "shopping") == :error

    # ** synchronous call
    KV.ETSRegistry.create(registry, "shopping")

    # ** assert pattern to match
    assert {:ok, _} = KV.ETSRegistry.lookup(registry, "shopping")
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.ETSRegistry.create(registry, "shopping")
    {:ok, shopping} = KV.ETSRegistry.lookup(registry, "shopping")

    # ** sending :normal exit reason -> {:DOWN, ref, ...}
    Agent.stop(shopping)

    # ** (Sync) wait until the bucket gets removed from the table
    # ** Do a call to ensure the registry processed the DOWN message
    KV.Registry.create(registry, "wait until handle_info finishes")

    assert KV.ETSRegistry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.ETSRegistry.create(registry, "shopping")
    {:ok, shopping} = KV.ETSRegistry.lookup(registry, "shopping")

    # ** sending :shutdown exit reason -> {:EXIT, ref, ...}
    Agent.stop(shopping, :shutdown)

    # ** (Sync) wait until the bucket gets removed from the table
    # ** Do a call to ensure the registry processed the DOWN message
    KV.Registry.create(registry, "wait until handle_info finishes")

    assert KV.ETSRegistry.lookup(registry, "shopping") == :error
  end

  test "crashed bucket should not be usable", %{registry: registry} do
    KV.ETSRegistry.create(registry, "shopping")
    {:ok, shopping} = KV.ETSRegistry.lookup(registry, "shopping")

    # ** Simulate a bucket crash by explicitly and synchronously shutting it down
    # ** sending :shutdown exit reason -> {:EXIT, ref, ...}
    Agent.stop(shopping, :shutdown)

    # ** Now trying to call the dead process causes a :noproc exit
    catch_exit(KV.Bucket.put(shopping, "milk", 3))
  end

  # test "log unexpected message" do
  # end
end
