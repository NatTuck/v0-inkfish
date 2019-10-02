defmodule Inkfish.ChannelRelay do
  def broadcast(channel, tag, body) do
    GenServer.cast(InkfishWeb.ChannelRelay, {:broadcast, channel, tag, body})
  end
end
