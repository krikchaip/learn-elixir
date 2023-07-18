defmodule KV.Registry do
  use GenServer

  # ** Client APIs

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # ** Defining GenServer Callbacks

  @impl true
  def init(:ok) do
    # ** %{name => bucket}
    names = %{}

    # ** %{process.ref => name}
    refs = %{}

    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, state) do
    {names, refs} = state

    if Map.has_key?(names, name) do
      {:noreply, state}
    else
      # ** start bucket process and link to registry server process
      # {:ok, bucket} = KV.Bucket.start_link([])

      # ** use DynamicSupervisor to handle bucket process instead
      {:ok, bucket} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)

      # ** registry process will supervise bucket process during creation
      ref = Process.monitor(bucket)

      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)

      {:noreply, {names, refs}}
    end
  end

  @impl true
  # ** will receive message from Agent.stop(bucket, :normal) call because of line#48
  def handle_info({:DOWN, ref, :process, _pid, _reason} = _msg, {names, refs}) do
    # ** remove related record from the state
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)

    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    # ** registry server should receive messages only from buckets. no where else.
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")

    {:noreply, state}
  end
end
