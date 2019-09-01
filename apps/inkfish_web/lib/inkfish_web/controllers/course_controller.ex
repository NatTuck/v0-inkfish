defmodule InkfishWeb.CourseController do
  use InkfishWeb, :controller

  alias Inkfish.Courses
  alias Inkfish.Courses.Course

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "id"]
    when action not in [:index]
  plug Plugs.RequireReg
    when action not in [:index]

  def index(conn, _params) do
    courses = Courses.list_courses()
    regs = Inkfish.Users.list_regs_for_user(conn.assigns[:current_user])
    reqs = Inkfish.JoinReqs.list_for_user(conn.assigns[:current_user])
    render(conn, "index.html", courses: courses, regs: regs, reqs: reqs)
  end

  def show(conn, %{"id" => id}) do
    course = Courses.get_course_for_student_view!(id)
    render(conn, "show.html", course: course)
  end
end
