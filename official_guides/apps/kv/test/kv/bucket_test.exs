defmodule KV.Bucket.Test do
  # ** makes the test case run in parallel with other :async test cases
  use ExUnit.Case, async: true

  # ** it's like beforeEach in some Javascript testing framework
  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "new bucket should be empty", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "stores values by key", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "delete bucket entry by key", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", 4)
    assert KV.Bucket.delete(bucket, "milk") == 4
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
