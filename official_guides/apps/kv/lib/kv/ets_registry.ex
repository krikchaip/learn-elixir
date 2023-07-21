defmodule KV.ETSRegistry do
  use GenServer

  # ** Client APIs

  @doc """
  Starts the registry with the given options.

  `:name` is always required.
  """
  def start_link(opts \\ []) do
    # ** 1. Pass the name to GenServer's init
    table_name = Keyword.fetch!(opts, :name)

    # ** table name and registry process name are the same at this point
    GenServer.start_link(__MODULE__, table_name, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(registry, name) do
    # ** 3. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(registry, name) do
      [{^name, bucket_pid}] -> {:ok, bucket_pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(registry, name) do
    # ** 7. To prevent race conditions
    GenServer.call(registry, {:create, name})
  end

  # ** Defining GenServer Callbacks

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  @impl GenServer
  def init(table_name) do
    # ** 2. We have replaced the names map by the ETS table
    # ** ets((name: string) => (bucket: pid))
    names =
      :ets.new(table_name, [
        :named_table,
        :set,
        :protected,
        read_concurrency: true
      ])

    # ** %{(ref: process.ref) => (name: string)}
    refs = %{}

    {:ok, {names, refs}}
  end

  # ** 4. The previous handle_call callback for lookup was removed
  # def handle_call(_request, _from, _state)

  @impl GenServer
  def handle_call({:create, name}, _from, {names, refs} = state) do
    # ** 5. Read and write to the ETS table instead of the map
    case lookup(names, name) do
      {:ok, bucket_pid} ->
        {:reply, bucket_pid, state}

      :error ->
        # ** use DynamicSupervisor to handle bucket process
        {:ok, bucket_pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)

        # ** registry will received a message from a bucket once it dies
        ref = Process.monitor(bucket_pid)

        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, bucket_pid})

        {:reply, bucket_pid, {names, refs}}
    end
  end

  @impl GenServer
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # ** 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)

    {:noreply, {names, refs}}
  end

  @impl GenServer
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")

    {:noreply, state}
  end
end
