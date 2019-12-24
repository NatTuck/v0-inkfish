defmodule Inkfish.Itty do
  alias Inkfish.Itty.Server

  def start(cmd) do
    Server.start(cmd, [])
  end

  def start(cmd, env) do
    Server.start(cmd, env)
  end

  def open(uuid) do
    open(uuid, self())
  end

  def open(uuid, rpid) do
    Server.open(uuid, rpid)
  end

  def close(uuid) do
    close(uuid, self())
  end

  def close(uuid, rpid) do
    Server.close(uuid, rpid)
  end
end
