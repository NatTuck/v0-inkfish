defmodule InkfishWeb.CloneChannel do
  use InkfishWeb, :channel

  def join("clone:" <> ch_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :id, ch_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("clone", %{"url" => url}, socket) do
    IO.inspect({:clone, url})
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (clone:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
