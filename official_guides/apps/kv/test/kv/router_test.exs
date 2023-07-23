defmodule KV.Router.Test do
  # ** must be run with `elixir --sname a -S mix test`
  # ** with node `b` already launched

  use ExUnit.Case, async: true

  @tag :distributed
  # @tag distributed: true
  test "route requests across nodes" do
    assert KV.Router.route("a", Kernel, :node, []) == :"a@Krikchais-MacBook-Pro-M1"
    assert KV.Router.route("n", Kernel, :node, []) == :"b@Krikchais-MacBook-Pro-M1"
  end

  test "raises an unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route("ก", Kernel, :node, [])
    end
  end
end
