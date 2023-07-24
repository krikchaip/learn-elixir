defmodule KV.Router.Test do
  # ** must be run with `elixir --sname a -S mix test --only distributed`
  # ** with node `b` already launched by calling `iex --sname b -S mix`

  use ExUnit.Case

  # ** =~ beforeAll() in Javascript world
  setup_all do
    current = Application.get_env(:kv, :routing_table)

    Application.put_env(:kv, :routing_table, [
      {?a..?m, :"a@Krikchais-MacBook-Pro-M1"},
      {?n..?z, :"b@Krikchais-MacBook-Pro-M1"}
    ])

    # ** =~ afterAll() in Javascript world
    on_exit(fn -> Application.put_env(:kv, :routing_table, current) end)
  end

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
