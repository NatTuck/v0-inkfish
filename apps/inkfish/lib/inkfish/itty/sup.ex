defmodule Inkfish.Itty.Sup do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Inkfish.Itty.DynSup},
      {Registry, keys: :unique, name: Inkfish.Itty.Reg},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
