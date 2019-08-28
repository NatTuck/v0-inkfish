defmodule InkfishWeb.CourseController do
  use InkfishWeb, :controller

  alias Inkfish.Courses
  alias Inkfish.Courses.Course

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg
    when action not in [:index, :new, :create]

  def index(conn, _params) do
    courses = Courses.list_courses()
    regs = Inkfish.Users.list_regs_for_user(conn.assigns[:current_user])
    reqs = Inkfish.JoinReqs.list_for_user(conn.assigns[:current_user])
    render(conn, "index.html", courses: courses, regs: regs, reqs: reqs)
  end

  def new(conn, _params) do
    changeset = Courses.change_course(%Course{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course" => course_params}) do
    case Courses.create_course(course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: Routes.course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    course = Courses.get_course_for_student_view!(id)
    render(conn, "show.html", course: course)
  end

  def edit(conn, %{"id" => id}) do
    course = Courses.get_course!(id)
    changeset = Courses.change_course(course)
    render(conn, "edit.html", course: course, changeset: changeset)
  end

  def update(conn, %{"id" => id, "course" => course_params}) do
    course = Courses.get_course!(id)

    case Courses.update_course(course, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: Routes.course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", course: course, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    course = Courses.get_course!(id)
    {:ok, _course} = Courses.delete_course(course)

    conn
    |> put_flash(:info, "Course deleted successfully.")
    |> redirect(to: Routes.course_path(conn, :index))
  end
end
