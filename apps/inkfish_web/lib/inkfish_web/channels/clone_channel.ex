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
    channel = "clone:" <> socket.assigns[:id]
    user_id = socket.assigns[:user_id]
    {:ok, _} = Inkfish.Uploads.Git.start_clone(url, channel, user_id)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
