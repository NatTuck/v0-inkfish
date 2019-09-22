defmodule InkfishWeb.ChannelRelay do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def broadcast(channel, tag, body) do
    GenServer.cast(__MODULE__, {:broadcast, channel, tag, body})
  end

  ## Callbacks
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:broadcast, channel, tag, body}, state) do
    InkfishWeb.Endpoint.broadcast(channel, tag, body)
    {:noreply, state}
  end
end
