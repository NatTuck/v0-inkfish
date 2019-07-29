defmodule Sandbox.Git do
  alias Sandbox.TempFs
  alias Sandbox.Shell

  def clone(url, dst, max_size) do
    base = Path.basename(dst)
    dir  = Path.dirname(dst)
    tdir = TempFs.make_tempfs(max_size)

    {text, code} = Shell.run_script """
    cd "#{tdir}" && git clone #{url} #{base}
    """

    if code == 0 do
      File.mkdir_p!(dir)
      {_, 0} = Shell.run_script """
      cp -r "#{tdir}/#{base}" "#{dst}"
      """
      :ok
    else
      {:error, text}
    end
  end
end
