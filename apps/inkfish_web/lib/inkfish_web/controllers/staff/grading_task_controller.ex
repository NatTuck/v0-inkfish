defmodule InkfishWeb.Staff.GradingTaskController do
  use InkfishWeb, :controller

  plug InkfishWeb.Plugs.FetchItem, [assignment: "assignment_id"]
  plug InkfishWeb.Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {:show, :staff, :assignment}

  alias Inkfish.Assignments
  alias Inkfish.Courses

  def show(conn, _params) do
    %{course: course, assignment: as, current_user: user} = conn.assigns

    graders = Courses.list_course_graders(course)

    tasks = Assignments.list_grading_tasks(as)

    user_tasks = Enum.filter tasks, fn grade ->
      grade.grader_id == user.id
    end

    render(conn, "show.html", graders: graders,
      tasks: tasks, user_tasks: user_tasks)
  end

  def create(conn, _params) do
    %{assignment: as} = conn.assigns

    Inkfish.Assignments.GradingTasks.assign_grading_tasks(as)

    conn
    |> put_flash(:info, "Grading has been assigned.")
    |> redirect(to: Routes.staff_assignment_grading_task_path(conn, :show, as))
  end

  def edit(conn, _params) do
    %{assignment: as} = conn.assigns

    render(conn, "edit.html")
  end

  def update(conn, _params) do
    %{assignment: as} = conn.assigns

    conn
    |> put_flash(:error, "TODO: Update grading")
    |> redirect(to: Routes.staff_assignment_grading_task_path(conn, :show, as))
  end
end
