defmodule InkfishWeb.CourseController do
  use InkfishWeb, :controller

  alias Inkfish.Courses

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "id"]
    when action not in [:index]
  plug Plugs.RequireReg
    when action not in [:index]

  plug Plugs.RequireUser

  def index(conn, _params) do
    courses = Courses.list_courses()
    regs = Inkfish.Users.list_regs_for_user(conn.assigns[:current_user])
    reqs = Inkfish.JoinReqs.list_for_user(conn.assigns[:current_user])
    render(conn, "index.html", courses: courses, regs: regs, reqs: reqs)
  end

  def show(conn, %{"id" => id}) do
    current_reg = conn.assigns[:current_reg]
    course = Courses.get_course_for_student_view!(id)
    |> Courses.preload_subs_for_student!(current_reg.id)
    teams = Courses.get_teams_for_student!(course, current_reg)
    render(conn, "show.html", course: course, teams: teams)
  end
end
