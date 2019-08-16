defmodule Inkfish.Exec do
  def run(cmd, pid) do
    cmd = to_charlist(cmd)
    :exec.run(cmd, [:sync, {:stdout, pid}, {:stderr, pid}])
  end

  def system(cmd) do
    cmd = to_charlist(cmd)
    :exec.run(cmd, [:sync, :stdout, :stderr])
  end
end
