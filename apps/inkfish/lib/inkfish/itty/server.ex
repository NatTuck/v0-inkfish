defmodule Inkfish.Itty.Server do
  use GenServer

  # How long to stay alive waiting for late
  # subscribers after the process terminates.
  @linger_seconds 60

  def start_link(uuid, cmd, env) do
    GenServer.start_link(__MODULE__, {uuid, cmd, env}, name: reg(uuid))
  end

  def reg(uuid) do
    {:via, Registry, {Inkfish.Itty.Reg, uuid}}
  end

  @doc """
  Create a new imaginary tty executing the provided command.

  Returns a uuid.
  """
  def start(cmd, env) do
    uuid = :crypto.strong_rand_bytes(16) |> Base.encode16
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [uuid, cmd, env]},
      restart: :temporary,
    }
    {:ok, _cpid} = DynamicSupervisor.start_child(Inkfish.Itty.DynSup, spec)
    {:ok, uuid}
  end

  @doc """
  Opens a link to an imaginary tty.

  Returns all previous output.

  Subscribes remote pid to recieve messages on future output.
  """
  def open(uuid, rpid) do
    GenServer.call(reg(uuid), {:open, rpid})
  end

  @doc """
  Unsubscribes from this tty.

  Returns {:ok, result_text}
  """
  def close(uuid, rpid) do
    GenServer.call(reg(uuid), {:close, rpid})
  end

  @impl true
  def init({cookie, cmd, env}) do
    env = [{"COOKIE", cookie} | env]
    |> Enum.map(fn {kk, vv} ->
      {to_charlist(to_string(kk)), to_charlist(vv)} end
    )

    cmd
    |> to_charlist()
    |> :exec.run([{:env, env}, {:stdout, self()}, {:stderr, self()}, :monitor])

    state0 = %{
      cookie: cookie,
      stdout: [],
      stderr: [],
      exit: nil,
      subs: MapSet.new(),
    }

    {:ok, state0}
  end

  @impl true
  def handle_call({:open, rpid}, _from, state0) do
    resp = %{
      stdout: state0.stdout |> Enum.reverse |> Enum.join(""),
      stderr: state0.stderr |> Enum.reverse |> Enum.join(""),
      exit: state0.exit,
    }
    state1 = Map.update! state0, :subs, &(MapSet.put(&1, rpid))
    {:reply, {:ok, resp}, state1}
  end

  def handle_call({:close, rpid}, _from, state0) do
    state1 = Map.update! state0, :subs, &(MapSet.delete(&1, rpid))
    result = get_output(state1.stdout, state1.cookie)
    {:reply, {:ok, result}, state1}
  end

  def handle_info({:stdout, _, text}, state0) do
    state1 = Map.update! state0, :stdout, &([text | &1])
    broadcast(state1.subs, {:stdout, text})
    {:noreply, state1}
  end

  @impl true
  def handle_info({:stderr, _, text}, state0) do
    state1 = Map.update! state0, :stderr, &([text | &1])
    broadcast(state1.subs, {:stderr, text})
    {:noreply, state1}
  end

  def handle_info({:DOWN, _, _, _, status}, state0) do
    state1 = Map.put state0, :exit, status
    broadcast(state1.subs, {:exit, status})
    Process.send_after(self(), :shutdown, @linger_seconds * 1000)
    {:noreply, state1}
  end

  def handle_info(:shutdown, state0) do
    {:stop, :normal, state0}
  end

  def broadcast(pids, msg) do
    Enum.each pids, fn pid ->
      send pid, msg
    end
  end

  def get_output(lines, cookie) do
    splits = lines
    |> Enum.reverse
    |> Enum.join("")
    |> String.split("\n#{cookie}\n", parts: 2, trim: true)

    case splits do
      [_, outp] -> outp
      _ -> ""
    end
  end
end
