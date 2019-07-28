defmodule Sandbox.Archive do

  alias Sandbox.TempFs
  alias Sandbox.Traverse

  @doc """
  Safely extract an archive file.
  """
  def safe_extract(archive, target, max_size) do
    archive = Path.expand(archive)
    target  = Path.expand(target)
    tdir = TempFs.make_tempfs(max_size)
    case untar(archive, tdir) do
      :ok ->
        sanitize_links!(tdir)
        {_, 0} = System.cmd("bash", ["-c", ~s(cp -r "#{tdir}" "#{target}")])
        :ok
      {:error, text} ->
        {:error, text}
    end
  end

  def sanitize_links!(base) do
    full = Path.expand(base)
    Traverse.walk full, fn (path, stat) ->
      if stat.type == :symlink do
        sanitize_link!(path, base)
      end
    end
  end

  def sanitize_link!(path, base) do
    {targ, 0} = System.cmd("readlink", ["-f", path])
    targ = String.trim(targ)
    pref = String.slice(targ, 0, String.length(base))
    if pref != base do
      IO.puts("removing unsafe link: '#{path}' => '#{targ}'")
      File.rm!(path)
    end
  end

  def untar(archive, target) do
    File.mkdir_p!(target)
    {:ok, script} = Temp.open "unpack", fn fd ->
      IO.write fd, """
      cd "#{target}" && tar xvf "#{archive}"
      """
    end
    {text, code} = System.cmd("bash", [script], stderr_to_stdout: true)
    File.rm(script)
    if code == 0 do
      :ok
    else
      {:error, text}
    end
  end
end
