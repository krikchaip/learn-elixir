defmodule KVServer.Acceptor do
  alias KVServer.Command

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
    output =
      with {:ok, line} <- :gen_tcp.recv(client, 0),
           {:ok, command} <- Command.parse(line),
           do: Command.run(command)

    case output do
      {:ok, text} ->
        :gen_tcp.send(client, text)

      # ** Known error; write to the client
      # ** source -> Command.parse/1
      {:error, :unknown_command} ->
        :gen_tcp.send(client, "UNKNOWN COMMAND\r\n")

      # ** The connection was closed, exit politely
      # ** source -> :gen_tcp.recv/2
      {:error, :closed} ->
        exit(:shutdown)

      # ** Handle when no bucket found
      # ** source -> KV.Registry.lookup/2
      {:error, :not_found} ->
        :gen_tcp.send(client, "NOT FOUND\r\n")

      # ** Unknown error; write to the client and exit
      {:error, error} ->
        :gen_tcp.send(client, "ERROR\r\n")
        exit(error)
    end

    # ** await the next commands from the client
    serve(client)
  end
end
