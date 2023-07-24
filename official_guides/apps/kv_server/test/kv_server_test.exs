defmodule KVServer.Test do
  @moduledoc """
  Integration tests for KVServer
  """

  use ExUnit.Case

  # ** automatically capture anything that is logged while the test runs.
  # ** In case our test fails, the captured logs will be printed alongside the report.
  @moduletag :capture_log

  # ** Restart :kv on every test in order to reset test environment
  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  # ** Setup connection socket
  setup do
    options = [
      # ** receives data as binaries (instead of lists)
      :binary,

      # ** receives data line by line
      packet: :line,

      # ** blocks on `:gen_tcp.recv/2` until data is available
      active: false
    ]

    # ** connect to the KV Server
    {:ok, server} = :gen_tcp.connect(~c"localhost", 4040, options)

    %{server: server}
  end

  # @tag :distributed
  # @tag distributed: true
  test "server interaction", %{server: server} do
    assert send_and_recv(server, "UNKNOWN shopping\r\n") == "UNKNOWN COMMAND\r\n"
    assert send_and_recv(server, "GET shopping eggs\r\n") == "NOT FOUND\r\n"
    assert send_and_recv(server, "CREATE shopping\r\n") == "OK\r\n"
    assert send_and_recv(server, "PUT shopping eggs 3\r\n") == "OK\r\n"

    # ** GET returns two lines
    assert send_and_recv(server, "GET shopping eggs\r\n") == "3\r\n"
    assert send_and_recv(server, "") == "OK\r\n"

    assert send_and_recv(server, "DELETE shopping eggs\r\n") == "OK\r\n"

    # ** GET returns two lines
    assert send_and_recv(server, "GET shopping eggs\r\n") == "\r\n"
    assert send_and_recv(server, "") == "OK\r\n"
  end

  defp send_and_recv(socket, line) do
    :ok = :gen_tcp.send(socket, line)

    # ** will wait up to 1 sec for each response
    {:ok, resp} = :gen_tcp.recv(socket, 0, 1000)

    resp
  end
end
