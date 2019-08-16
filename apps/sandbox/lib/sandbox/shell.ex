defmodule Sandbox.Shell do
  @doc """
  Run text as a shell script.

  This is *not* sandboxed.
  """
  def run_script(text) do
    {:ok, script} = Temp.open "unpack", fn fd ->
      IO.write(fd, text)
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
