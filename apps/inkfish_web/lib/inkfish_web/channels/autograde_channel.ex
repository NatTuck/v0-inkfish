defmodule InkfishWeb.AutogradeChannel do
  use InkfishWeb, :channel

  alias Inkfish.Grades

  def join("autograde:" <> uuid, %{"token" => token}, socket) do
    case Phoenix.Token.verify(InkfishWeb.Endpoint, "autograde", token, max_age: 8640) do
      {:ok, %{uuid: ^uuid}} ->
        socket = socket
        |> assign(:uuid, uuid)

        {:ok, %{output: output, exit: exit}} = Inkfish.Itty.open(uuid)
        Enum.each output, fn item ->
          send(self(), {:output, item})
        end

        if exit do
          send(self(), {:exit, exit})
        end

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
    data = %{
      serial: 8_000_000_000,
      stream: "stderr",
      text: "\n-- exit: #{inspect(status)} --",
    }
    push(socket, "output", data)

    Process.send_after(self(), :show_score, 1_000)
  end

  def handle_info(:show_score, socket) do
    grade = Grades.get_grade_by_log_uuid(socket.assigns[:uuid])
    if grade do
      data = %{
        serial: 8_000_000_001,
        stream: "stderr",
        text: "\n\nyour score: #{grade.score} / #{grade.grade_column.points}",
      }
      push(socket, "output", data)
    else
      data = %{
        serial: 8_000_000_001,
        stream: "stderr",
        text: "\n\ncan't find grade to see score",
      }
      push(socket, "output", data)
    end

    {:noreply, socket}
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
