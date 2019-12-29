defmodule InkfishWeb.CloneChannel do
  use InkfishWeb, :channel
  alias Inkfish.Uploads.Git

  def join("clone:" <> ch_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :id, ch_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("clone", %{"url" => url}, socket) do
    #channel = "clone:" <> socket.assigns[:id]
    #user_id = socket.assigns[:user_id]
    {:ok, uuid, data} = Git.start_clone(url)
    push(socket, "print", %{text: data.stdout})
    push(socket, "print", %{text: data.stderr})
    socket = assign(socket, :uuid, uuid)
    {:noreply, socket}
  end

  def handle_info({:stdout, text}, socket) do
    IO.inspect(text)
    push(socket, "print", %{text: text})
    {:noreply, socket}
  end

  def handle_info({:stderr, text}, socket) do
    push(socket, "print", %{text: text})
    {:noreply, socket}
  end

  def handle_info({:exit, status}, socket) do
    {:ok, results} = Git.get_results(socket.assigns[:uuid])
    push(socket, "print", %{text: inspect({status, results})})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
