defmodule InkfishWeb.Staff.AssignmentController do
  use InkfishWeb, :controller

  plug InkfishWeb.Plugs.FetchItem, [bucket: "bucket_id"]
    when action in [:index, :new, :create]
  plug InkfishWeb.Plugs.FetchItem, [assignment: "id"]
    when action not in [:index, :new, :create]

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {:show, :staff, :bucket}

  alias Inkfish.Assignments
  alias Inkfish.Assignments.Assignment

  def index(conn, _params) do
    assignments = Assignments.list_assignments()
    render(conn, "index.html", assignments: assignments)
  end

  def new(conn, params) do
    teamsets = Inkfish.Teams.list_teamsets(conn.assigns[:course])
    as = %Assignment{
      bucket_id: params["bucket_id"],
      teamset_id: hd(teamsets).id,
      weight: Decimal.new("1.0"),
    }
    changeset = Assignments.change_assignment(as)
    render(conn, "new.html", changeset: changeset, teamsets: teamsets)
  end

  def create(conn, %{"assignment" => assignment_params}) do
    case Assignments.create_assignment(assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment created successfully.")
        |> redirect(to: Routes.staff_assignment_path(conn, :show, assignment))

      {:error, %Ecto.Changeset{} = changeset} ->
        teamsets = Inkfish.Teams.list_teamsets(conn.assigns[:course])
        render(conn, "new.html", changeset: changeset, teamsets: teamsets)
    end
  end

  def show(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    render(conn, "show.html", assignment: assignment)
  end

  def edit(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    changeset = Assignments.change_assignment(assignment)
    teamsets = Inkfish.Teams.list_teamsets(conn.assigns[:course])
    render(conn, "edit.html", assignment: assignment,
      changeset: changeset, teamsets: teamsets)
  end

  def update(conn, %{"id" => id, "assignment" => assignment_params}) do
    assignment = Assignments.get_assignment!(id)

    case Assignments.update_assignment(assignment, assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment updated successfully.")
        |> redirect(to: Routes.staff_assignment_path(conn, :show, assignment))

      {:error, %Ecto.Changeset{} = changeset} ->
        teamsets = Inkfish.Teams.list_teamsets(conn.assigns[:course])
        render(conn, "edit.html", assignment: assignment, changeset: changeset,
          teamsets: teamsets)
    end
  end

  def delete(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    {:ok, _assignment} = Assignments.delete_assignment(assignment)

    conn
    |> put_flash(:info, "Assignment deleted successfully.")
    |> redirect(to: Routes.staff_assignment_path(conn, :index))
  end
end
