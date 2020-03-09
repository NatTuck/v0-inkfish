defmodule Inkfish.Autograde.Server do
  use GenServer

  alias Inkfish.Itty
  alias Inkfish.Grades
  alias Inkfish.Grades.Grade
  alias Inkfish.Uploads.Upload
  alias Inkfish.Autograde.Tap

  def start_link(grade_id) do
    GenServer.start_link(__MODULE__, grade_id)
  end

  def start(grade_id) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [grade_id]},
      restart: :temporary,
    }
    DynamicSupervisor.start_child(Inkfish.Autograde.Sup, spec)
  end

  def get_uuid(pid) do
    GenServer.call(pid, :get_uuid)
  end

  @impl true
  def init(grade_id) do
    priv = to_string(:code.priv_dir(:inkfish))
    script = Path.join(priv, "scripts/autograde.pl")
    driver = Path.join(priv, "scripts/grading-driver.pl")

    grade = Grades.get_grade_for_autograding!(grade_id)

    {:ok, uuid} = Itty.start(
      script,
      GID: grade_id,
      SUB: Upload.upload_path(grade.sub.upload),
      GRA: Upload.upload_path(grade.grade_column.upload),
      DRV: driver
    )

    {:ok, %{exit: status, output: data}} = Itty.open(uuid)

    state = %{
      grade_id: grade_id,
      uuid: uuid,
      data: data,
    }

    if status do
      Process.send_after(self(), {:exit, status}, 10)
    end

    {:ok, state}
  end

  @impl true
  def handle_call(:get_uuid, _from, state) do
    {:reply, {:ok, state.uuid}, state}
  end

  @impl true
  def handle_info({:output, item}, state) do
    IO.inspect({:autograde, :output, item})
    state = Map.update!(state, :data, &([item | &1]))
    {:noreply, state}
  end

  def handle_info({:exit, status}, state) do
    {:ok, result} = Itty.close(state.uuid)

    log = state.data
    |> Enum.sort_by(fn {serial, _, _} -> serial end)
    |> Enum.map(fn {serial, stream, text} ->
      %{
        serial: serial,
        stream: stream,
        text: sanitize_utf8(text),
      }
    end)

    data = %{
      status: inspect(status),
      result: result,
      log: log,
    }
    json = Jason.encode!(data)
    grade = Grades.get_grade_for_autograding!(state.grade_id)
    path = Grade.log_path(grade)
    File.write!(path, json)

    if status == :normal do
      {:ok, {passed, total}} = Tap.score(result)
      score = passed
      |> Decimal.div(total)
      |> Decimal.mult(grade.grade_column.points)
      {:ok, _} = Grades.update_grade(grade, %{score: score})
      {:ok, _} = Inkfish.Subs.calc_sub_score!(grade.sub_id)
    end

    {:stop, :normal, state}
  end

  def sanitize_utf8(text) do
    text
    |> String.codepoints
    |> Enum.filter(&String.valid?/1)
    |> Enum.join("")
  end
end
