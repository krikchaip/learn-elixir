defmodule KVServer.Acceptor do
  require Logger

  @doc """
  Start accepting TCP connection on a specified `port`.
  """
  @spec accept(:inet.port_number()) :: no_return() | {:error, term()}
  def accept(port) do
    options = [
      # ** receives data as binaries (instead of lists)
      :binary,

      # ** receives data line by line
      packet: :line,

      # ** blocks on `:gen_tcp.recv/2` until data is available
      active: false,

      # ** allows us to reuse the address if the listener crashes
      reuseaddr: true
    ]

    # ** listen to the port until the socket becomes available
    case :gen_tcp.listen(port, options) do
      {:ok, socket} ->
        Logger.info("Accepting connections on port #{port}")
        accept_for_client(socket)

      {:error, _reason} = err ->
        err
    end
  end

  # ** Waiting for client connections one by one and serving each one
  @spec accept_for_client(:gen_tcp.socket()) :: no_return() | {:error, term()}
  defp accept_for_client(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        # ** (non-blocking) starts serving client under Task.Supervisor
        {:ok, serve_pid} =
          Task.Supervisor.start_child(
            KVServer.TaskSupervisor,
            fn -> serve(client) end
          )

        # ** will close a socket during client exits rather than letting the Acceptor crashes
        :ok = :gen_tcp.controlling_process(client, serve_pid)

        # ** await the next client
        accept_for_client(socket)

      {:error, _reason} = err ->
        err
    end
  end

  # ** Reads a line from the socket and writes those lines back to the socket.
  @spec serve(:gen_tcp.socket()) :: no_return()
  defp serve(client) do
    client
    |> read_line
    |> write_line
    |> serve
  end

  @spec read_line(socket) :: {socket, binary()} when socket: :gen_tcp.socket()
  defp read_line(socket) do
    {:ok, line} = :gen_tcp.recv(socket, 0)
    {socket, line}
  end

  @spec write_line({socket, binary()}) :: socket when socket: :gen_tcp.socket()
  defp write_line({socket, line}) do
    :ok = :gen_tcp.send(socket, line)
    socket
  end
end
