defmodule KVServer do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = System.get_env("PORT", "4040") |> String.to_integer()

    children = [
      # Starts a worker by calling: KVServer.Worker.start_link(arg)
      # {KVServer.Worker, arg}

      # ** required by the Acceptor below
      {Task.Supervisor, name: KVServer.TaskSupervisor},

      # ** Executes a given function inside a new process
      # ** that will be part of a supervision tree
      # ** calling Task.start_link(fn ... end)
      # {Task, fn -> KVServer.Acceptor.accept(port) end},

      # ** Override Task's default restart policy
      Supervisor.child_spec(
        {Task, fn -> KVServer.Acceptor.accept(port) end},
        restart: :permanent
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [
      name: KVServer.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end
end
