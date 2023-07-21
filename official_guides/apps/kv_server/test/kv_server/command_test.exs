defmodule KVServer.Command.Test do
  use ExUnit.Case, async: true

  # ** read @doc tags from KVServer.Command to generate test cases
  doctest KVServer.Command
end
