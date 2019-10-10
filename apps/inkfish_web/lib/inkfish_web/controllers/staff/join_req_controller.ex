defmodule InkfishWeb.Staff.JoinReqController do
  use InkfishWeb, :controller

  alias Inkfish.JoinReqs
  alias Inkfish.Users

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug Plugs.FetchItem, [join_req: "id"]
    when action not in [:index, :new, :create]

  plug Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {"Join Reqs", :staff_course_join_req, :index, :course}
    when action not in [:index]

  def index(conn, _params) do
    join_reqs = JoinReqs.list_for_course(conn.assigns[:course])
    render(conn, "index.html", join_reqs: join_reqs)
  end

  def show(conn, %{"id" => _id}) do
    join_req = conn.assigns[:join_req]
    render(conn, "show.html", join_req: join_req)
  end

  def accept(conn, %{"id" => _id}) do
    req = conn.assigns[:join_req]

    attrs = %{
      user_id: req.user_id,
      course_id: req.course_id,
      is_staff: req.staff_req,
      is_grader: req.staff_req,
      is_student: !req.staff_req,
      is_prof: false,
    }
    {:ok, _reg} = Users.create_reg(attrs)
    {:ok, _join_req} = JoinReqs.delete_join_req(req)

    conn
    |> put_flash(:info, "Join req accepted.")
    |> redirect(to: Routes.staff_course_join_req_path(conn, :index, conn.assigns[:course]))
  end

  def delete(conn, %{"id" => _id}) do
    join_req = conn.assigns[:join_req]
    {:ok, _join_req} = JoinReqs.delete_join_req(join_req)

    conn
    |> put_flash(:info, "Join req deleted successfully.")
    |> redirect(to: Routes.staff_course_join_req_path(conn, :index, conn.assigns[:course]))
  end
end
