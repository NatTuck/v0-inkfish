defmodule InkfishWeb.Staff.AssignmentController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs

  plug Plugs.FetchItem, [bucket: "bucket_id"]
    when action in [:index, :new, :create]
  plug Plugs.FetchItem, [assignment: "id"]
    when action not in [:index, :new, :create]

  plug Plugs.RequireReg, staff: true

  alias Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {:show, :staff, :assignment}
    when action not in [:index, :new, :create, :show]

  alias Inkfish.Assignments
  alias Inkfish.Assignments.Assignment

  def new(conn, params) do
    teamsets = Inkfish.Teams.list_teamsets(conn.assigns[:course])
    today = Inkfish.LocalTime.today()
    {:ok, due} = NaiveDateTime.new(Date.add(today, 7), ~T[23:59:59])
    as = %Assignment{
      bucket_id: params["bucket_id"],
      teamset_id: hd(teamsets).id,
      weight: Decimal.new("1.0"),
      due: due,
      allow_git: false,
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
    assignment = Assignments.get_assignment_for_staff!(id)
    subs = Assignments.list_active_subs(assignment)
    render(conn, "show.html", assignment: %{assignment | subs: subs})
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
    |> redirect(to: Routes.staff_course_path(conn, :show, conn.assigns[:course]))
  end

  def create_fake_subs(conn, %{"id" => _id}) do
    assignment = conn.assigns[:assignment]

    Assignments.create_fake_subs!(assignment, conn.assigns[:current_user])

    conn
    |> put_flash(:info, "Fake submissions created")
    |> redirect(to: Routes.staff_assignment_path(conn, :show, assignment))
  end
end
