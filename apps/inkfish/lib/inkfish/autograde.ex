defmodule Inkfish.Autograde do
  alias Inkfish.Autograde.Server

  @doc """
  Start the autograding process given a grade_id.

  Returns {:ok, uuid} for the associated Itty.
  """
  def start(grade_id) do
    {:ok, pid} = Server.start(grade_id)
    Server.get_uuid(pid)
  end
end
