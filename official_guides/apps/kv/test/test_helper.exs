# ** excludes tests with :distributed tag
exclude = if Node.alive?(), do: [], else: [distributed: true]

# ** see https://hexdocs.pm/ex_unit/ExUnit.html#configure/1 for more info regarding options
ExUnit.start(exclude: exclude)
