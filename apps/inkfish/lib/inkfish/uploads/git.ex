defmodule Inkfish.Uploads.Git do
  use GenServer

  def start_clone(url, channel, user_id) do
    state0 = %{url: url, channel: channel, user_id: user_id}
    GenServer.start_link(__MODULE__, state0)
  end

  def message(pid, msg) do
    GenServer.call(pid, {:print, msg})
  end

  def upload_done(pid, upload_id) do
    GenServer.call(pid, {:done, upload_id})
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
  def work(%{url: url, user_id: user_id}, spid) do
    max_megs = 10

    message(spid, "Creating temp dir...")
    {:ok, tdir} = Sandbox.make_tempfs("#{2*max_megs}M")

    message(spid, "Cloning git repo...")
    {:ok, gdir} = clone_repo(url, tdir, spid)

    message(spid, "Checking size...")
    {:ok, size} = check_size(Path.join(tdir, gdir), spid, max_megs)
    message(spid, "Size OK at #{size}k")

    message(spid, "Packing tarball...")
    {:ok, tarn} = pack_tarball(tdir, gdir, spid)
    tarp = Path.join(tdir, tarn)

    message(spid, "Creating upload...")
    attrs = %{kind: "sub", user_id: user_id, name: tarn}
    {:ok, upload} = Inkfish.Uploads.create_git_upload(attrs)
    Inkfish.Uploads.Upload.copy_file!(upload, tarp)

    message(spid, "Unpacking tarball...")
    :ok = Inkfish.Uploads.Upload.unpack(upload)

    message(spid, "Done. Upload is #{upload.id}")
    upload_done(spid, upload.id)
  end

  def clone_repo(url, tdir, spid) do
    cmd = ~s(cd "#{tdir}" && git clone --progress "#{url}")
    {:ok, _} = Inkfish.Exec.run(cmd, spid)
    {:ok, [gdir]} = File.ls(tdir)
    {:ok, gdir}
  end

  def check_size(path, _spid, max_megs) do
    {:ok, [stdout: text]} = Inkfish.Exec.system(~s(du -cks "#{path}" | tail -n 1))
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
    {:ok, tarname}
  end

  # GenServer callbacks

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, pid} = Task.start_link(__MODULE__, :work, [state, self()])
    state = Map.put(state, :wpid, pid)
    {:ok, state}
  end

  def handle_call({:done, upload_id}, _from, state) do
    channel = state[:channel]
    InkfishWeb.Endpoint.broadcast(channel, "done", %{upload_id: upload_id})
    {:reply, :ok, state}
  end

  def handle_call({:print, msg}, _from, state) do
    channel = state[:channel]
    InkfishWeb.Endpoint.broadcast(channel, "print", %{msg: "#{msg}\n"})
    {:reply, :ok, state}
  end

  def handle_info({:stdout, _, data}, state) do
    channel = state[:channel]
    msg = " o: #{data}"
    InkfishWeb.Endpoint.broadcast(channel, "print", %{msg: msg})
    {:noreply, state}
  end

  def handle_info({:stderr, _, data}, state) do
    channel = state[:channel]
    msg = " E: #{data}"
    InkfishWeb.Endpoint.broadcast(channel, "print", %{msg: msg})
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    wpid = state[:wpid]
    channel = state[:channel]
    if pid == wpid do
      case reason do
        :normal ->
          IO.inspect("Work task exited normally")
        {{:badmatch, error}, _} ->
          payload = %{ msg: inspect(error) }
          InkfishWeb.Endpoint.broadcast(channel, "fail", payload)
        _ ->
          IO.inspect({"unknown reason", reason})
      end
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  def handle_info(msg, state) do
    IO.inspect({:info, msg})
    {:noreply, state}
  end
end
