defmodule InkfishWeb.Staff.CourseController do
  use InkfishWeb, :controller

  plug InkfishWeb.Plugs.FetchItem, [course: "id"]
    when action not in [:index, :new, :create]

  plug InkfishWeb.Plugs.Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug InkfishWeb.Plugs.Breadcrumb, {:show, :staff, :course}
    when action not in [:index, :new, :create]

  alias Inkfish.Courses
  alias Inkfish.Courses.Course
  alias Inkfish.Grades.Gradesheet

  def index(conn, _params) do
    courses = Courses.list_courses()
    render(conn, "index.html", courses: courses)
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
        |> redirect(to: Routes.staff_course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    course = Courses.get_course_for_staff_view!(id)
    render(conn, "show.html", course: course)
  end

  def edit(conn, %{"id" => _id}) do
    course = conn.assigns[:course]
    changeset = Courses.change_course(course)
    render(conn, "edit.html", course: course, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "course" => course_params}) do
    course = conn.assigns[:course]

    case Courses.update_course(course, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: Routes.staff_course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", course: course, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    course = conn.assigns[:course]
    {:ok, _course} = Courses.delete_course(course)

    conn
    |> put_flash(:info, "Course deleted successfully.")
    |> redirect(to: Routes.staff_course_path(conn, :index))
  end

  def gradesheet(conn, %{"id" => id}) do
    course = Courses.get_course_for_gradesheet!(id)
    sheet = Gradesheet.from_course(course)
    render(conn, "gradesheet.html", fluid_grid: true,
      course: course, sheet: sheet)
  end
end
