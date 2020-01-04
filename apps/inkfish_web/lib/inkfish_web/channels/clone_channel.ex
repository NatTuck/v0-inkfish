defmodule InkfishWeb.CloneChannel do
  use InkfishWeb, :channel
  alias Inkfish.Uploads.Git

  def join("clone:" <> nonce, %{"token" => token}, socket) do
    case Phoenix.Token.verify(InkfishWeb.Endpoint, "upload", token, max_age: 8640) do
      {:ok, %{kind: kind, nonce: ^nonce}} ->
        socket = socket
        |> assign(:kind, kind)
        |> assign(:upload_id, nil)
        {:ok, socket}
      failure ->
        IO.inspect(failure)
        {:error, %{reason: "unauthorized"}}
    end
  end

  def send_output({serial, stream, text}, socket) do
    data = %{
      serial: serial,
      stream: stream,
      text: text,
    }
    push(socket, "output", data)
  end

  def got_exit(status, socket) do
    if status == :normal do
      {:ok, results} = Git.get_results(socket.assigns[:uuid])

      socket = if is_nil(socket.assigns[:upload_id]) do
        {:ok, upload} = Git.create_upload(
          results, socket.assigns[:kind], socket.assigns[:user_id])
        socket
        |> assign(:upload, %{"id" => upload.id, "name" => upload.name})
      else
        socket
      end

      data = %{
        status: "normal",
        results: results,
        upload: socket.assigns[:upload],
      }
      push(socket, "done", data)
    else
      data = %{
        status: status,
        results: "",
        upload_id: nil
      }
      push(socket, "done", data)
    end
  end

  def handle_in("clone", %{"url" => url}, socket) do
    {:ok, uuid} = Git.start_clone(url)
    socket = assign(socket, :uuid, uuid)
    {:ok, %{output: output, exit: exit}} = Inkfish.Itty.open(uuid)

    Enum.each output, fn item ->
      send_output(item, socket)
    end

    if exit do
      got_exit(exit, socket)
    end

    {:reply, :ok, socket}
  end

  def handle_info({:output, item}, socket) do
    send_output(item, socket)
    {:noreply, socket}
  end

  def handle_info({:exit, status}, socket) do
    got_exit(status, socket)
    {:noreply, socket}
  end
end
