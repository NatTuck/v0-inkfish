defmodule InkfishWeb.Admin.CourseController do
  use InkfishWeb, :controller

  alias Inkfish.Courses
  alias Inkfish.Courses.Course

  plug InkfishWeb.Plugs.RequireUser, admin: true

  plug InkfishWeb.Plugs.FetchItem, [course: "id"]
    when action not in [:index, :new, :create]

  plug InkfishWeb.Plugs.Breadcrumb, {"Admin Courses", :admin_course, :index}

  def index(conn, _params) do
    courses = Courses.list_courses()
    profs = Enum.map courses, fn course ->
      {course.id, Courses.get_one_course_prof(course)}
    end
    render(conn, "index.html", courses: courses, profs: Enum.into(profs, %{}))
  end

  def new(conn, _params) do
    defaults = %Course{
      start_date: Inkfish.LocalTime.today(),
    }
    changeset = Courses.change_course(defaults)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course" => course_params}) do
    case Courses.create_course(course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: Routes.admin_course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    course = Courses.get_course!(id)
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
        |> redirect(to: Routes.admin_course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", course: course, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    course = Courses.get_course!(id)
    {:ok, _course} = Courses.delete_course(course)

    conn
    |> put_flash(:info, "Course deleted successfully.")
    |> redirect(to: Routes.admin_course_path(conn, :index))
  end
end
