defmodule Sandbox.TempFs do
  def make_tempfs(max_size) do
    case System.cmd("tmptmpfs", ["start", "-s", max_size]) do
      {tdir, 0} -> {:ok, String.trim(tdir)}
      {_, code} -> {:error, "error #{code}"}
    end
  end
end
