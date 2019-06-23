defmodule InkfishWeb.AssignmentController do
  use InkfishWeb, :controller

  alias Inkfish.Assignments
  alias Inkfish.Assignments.Assignment

  def index(conn, _params) do
    assignments = Assignments.list_assignments()
    render(conn, "index.html", assignments: assignments)
  end

  def new(conn, _params) do
    changeset = Assignments.change_assignment(%Assignment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"assignment" => assignment_params}) do
    case Assignments.create_assignment(assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment created successfully.")
        |> redirect(to: Routes.assignment_path(conn, :show, assignment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    render(conn, "show.html", assignment: assignment)
  end

  def edit(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    changeset = Assignments.change_assignment(assignment)
    render(conn, "edit.html", assignment: assignment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "assignment" => assignment_params}) do
    assignment = Assignments.get_assignment!(id)

    case Assignments.update_assignment(assignment, assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment updated successfully.")
        |> redirect(to: Routes.assignment_path(conn, :show, assignment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", assignment: assignment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    {:ok, _assignment} = Assignments.delete_assignment(assignment)

    conn
    |> put_flash(:info, "Assignment deleted successfully.")
    |> redirect(to: Routes.assignment_path(conn, :index))
  end
end
