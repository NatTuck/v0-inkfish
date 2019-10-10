defmodule SandboxTest do
  use ExUnit.Case

  test "run a script" do
    assert Sandbox.Shell.run_script("true") == :ok
  end
end
