defmodule Inkfish.Itty do
  alias Inkfish.Itty.Server

  @doc """
  Returns {:ok, uuid}
  """
  def start(cmd) do
    Server.start(cmd, [])
  end

  def start(cmd, env) do
    Server.start(cmd, env)
  end

  @doc """
  Subscribes the current process to event messages.

  Returns {:ok, prev_data}
  """
  def open(uuid) do
    open(uuid, self())
  end

  def open(uuid, rpid) do
    Server.open(uuid, rpid)
  end

  @doc """
  Returns {:ok, output_text}
  """
  def close(uuid) do
    close(uuid, self())
  end

  def close(uuid, rpid) do
    Server.close(uuid, rpid)
  end
end
