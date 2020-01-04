defmodule InkfishWeb.AutogradeChannel do
  use InkfishWeb, :channel

  def join("autograde:" <> uuid, %{"token" => token}, socket) do
    case Phoenix.Token.verify(InkfishWeb.Endpoint, "autograde", token, max_age: 8640) do
      {:ok, %{uuid: uuid}} ->
        socket = socket
        |> assign(:uuid, uuid)
        {:ok, socket}
      failure ->
        IO.inspect(failure)
        {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (autograde:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
end
