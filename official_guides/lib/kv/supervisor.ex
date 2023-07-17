defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},

      # ** KV.Registry requires DynamicSupervisor to be started before itself
      {KV.Registry, name: KV.Registry}
    ]

    # ** if any of the children dies, kill and restart others
    Supervisor.init(children, strategy: :one_for_all)
  end
end
