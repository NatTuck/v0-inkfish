defmodule Sandbox.Archive do

  alias Sandbox.TempFs
  alias Sandbox.Traverse
  alias Sandbox.Shell

  @doc """
  Safely extract an archive file.
  """
  def safe_extract(archive, target, max_size) do
    archive = Path.expand(archive)
    target  = Path.expand(target)
    {:ok, tdir} = TempFs.make_tempfs(max_size)
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
    Shell.run_script """
    cd "#{target}" && tar xvf "#{archive}"
    """
  end

  def tar(src, archive) do
    dir  = Path.dir(src)
    base = Path.base(src)
    File.mkdir_p!(Path.dir(archive))
    Shell.run_script """
    cd "#{base}" && tar czvf "#{archive}"
    """
  end
end
