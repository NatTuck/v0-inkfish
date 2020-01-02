defmodule Sandbox.Container.Server do
  use GenServer

  def start_link(info) do
    GenServer.start_link(__MODULE__, info)
  end

  def exec(cmd) do
    cmd
    |> to_charlist
    |> :exec.run([{:stdout, self()}, {:stderr, self()}, :monitor])
  end

  def init(st) do
    {:ok, st}
  end
end
