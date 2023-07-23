defmodule KVServer.Command do
  alias KV.Bucket
  alias KV.ETSRegistry, as: Registry

  @type command ::
          {:create, bucket :: String.t()}
          | {:get, bucket :: String.t(), key :: String.t()}
          | {:put, bucket :: String.t(), key :: String.t(), value :: term()}
          | {:delete, bucket :: String.t(), key :: String.t()}

  # ** uses "~S" to prevent the \r\n characters from being converted
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> KVServer.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "CREATE  shopping  \r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "PUT shopping milk 1\r\n"
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> KVServer.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> KVServer.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> KVServer.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> KVServer.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}

  """
  @spec parse(line :: String.t()) :: {:ok, command()} | {:error, :unknown_command}
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command.
  """
  @spec run(command()) :: {:ok, String.t()} | {:error, :not_found}
  def run(command)

  def run({:create, bucket}) do
    {mod, fun, args} = {Registry, :create, [Registry, bucket]}

    case KV.Router.route(bucket, mod, fun, args) do
      bucket_pid when is_pid(bucket_pid) -> {:ok, "OK\r\n"}
      _ -> {:error, "FAILED TO CREATE BUCKET"}
    end
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn bucket_pid ->
      value = Bucket.get(bucket_pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn bucket_pid ->
      Bucket.put(bucket_pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn bucket_pid ->
      Bucket.delete(bucket_pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(bucket, callback) do
    {mod, fun, args} = {Registry, :lookup, [Registry, bucket]}

    # ** Instead of directly looking up the registry,
    # ** we are using the router instead to match a specific node
    case KV.Router.route(bucket, mod, fun, args) do
      {:ok, bucket_pid} -> callback.(bucket_pid)
      :error -> {:error, :not_found}
    end
  end
end
