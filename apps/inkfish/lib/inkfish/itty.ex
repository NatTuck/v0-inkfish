defmodule Inkfish.Itty do
  alias Inkfish.Itty.Server

  @doc """
  Returns {:ok, uuid}
  """
  def start(cmd) do
    Server.start(cmd, [], &null_fn/1)
  end

  def start(cmd, env) do
    Server.start(cmd, env, &null_fn/1)
  end

  def start(cmd, env, on_exit) do
    Server.start(cmd, env, on_exit)
  end

  defp null_fn(_) do
    :ok
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
