defmodule Inkfish.Uploads.Git do
  use GenServer

  def start_clone(url, channel) do
    state0 = %{url: url, channel: channel}
    GenServer.start_link(__MODULE__, state0)
  end

  def message(pid, msg) do
    Process.send_after(pid, {:print, msg}, 0)
  end

  # Implementation

  # Stages:
  #  - Create temp dir
  #  - Run git clone
  #  - Check size
  #  - Create tarball
  #  - Create Upload
  #  - Unpack tarball
  #  - Send success message with Upload ID.

  # Task to do the work.
  def work(%{url: url, channel: channel}, spid) do
    max_megs = 10

    message(spid, "Creating temp dir...")
    {:ok, tdir} = Sandbox.make_tempfs("#{2*max_megs}M")

    message(spid, "Cloning git repo...")
    {:ok, gdir} = clone_repo(url, tdir, spid)

    message(spid, "Checking size...")
    {:ok, size} = check_size(Path.join(tdir, gdir), spid, max_megs)

    message(spid, "Packing tarball...")
    {:ok, tarp} = pack_tarball(tdir, gdir, spid)

    IO.inspect({:tarball_packed, tarp})
  end

  def clone_repo(url, tdir, spid) do
    cmd = ~s(cd "#{tdir}" && git clone --progress "#{url}")
    {:ok, _} = Inkfish.Exec.run(cmd, spid)
    {:ok, [gdir]} = File.ls(tdir)
    {:ok, gdir}
  end

  def check_size(path, spid, max_megs) do
    {:ok, [stdout: text]} = Inkfish.Exec.system(~s(du -cks "#{path}" | tail -n 1))
    IO.inspect({:text, text})
    {size, _} = Integer.parse(Enum.join(text))
    if size <= (max_megs * 1024) do
      {:ok, size}
    else
      {:error, "Too big: #{size}k"}
    end
  end

  def pack_tarball(tdir, gdir, spid) do
    tarname = "#{gdir}.tar.gz"
    cmd = ~s(cd "#{tdir}" && tar czvf "#{tarname}" "#{gdir}")
    {:ok, _} = Inkfish.Exec.run(cmd, spid)
    {:ok, Path.join(tdir, tarname)}
  end

  # GenServer callbacks

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, pid} = Task.start_link(__MODULE__, :work, [state, self()])
    state = Map.put(state, :wpid, pid)
    {:ok, state}
  end

  def handle_info({:print, msg}, state) do
    IO.inspect({:msg, msg})
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    wpid = state[:wpid]
    if pid == wpid do
      case reason do
        {{:badmatch, error}, _} ->
          IO.inspect({"got error", error})
        _ ->
          IO.inspect({"unknown reason", reason})
      end
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info(msg, state) do
    IO.inspect({:info, msg})
    {:noreply, state}
  end
end
