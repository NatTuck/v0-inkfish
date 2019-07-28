defmodule Sandbox.TempFs do
  def make_tempfs(max_size) do
    {tdir, 0} = System.cmd("tmptmpfs", ["start", "-s", max_size])
    String.trim(tdir)
  end
end
