defmodule Sandbox.Traverse do
  def walk(path, op) do
    case File.lstat(path, time: :posix) do
      {:ok, stat} ->
        op.(path, stat)
        if stat.type == :directory do
          walk_dir(path, op)
        end
      {:error, _} ->
        []
    end
  end

  def walk_dir(path, op) do
    Enum.each File.ls!(path), fn name ->
      walk(Path.join(path, name), op)
    end
  end
end
