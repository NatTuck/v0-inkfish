defmodule InkfishWeb.Staff.SubController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [sub: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.FetchItem, [assignment: "assignment_id"]
    when action in [:index, :new, :create]
  plug Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {:show, :staff, :assignment}

  alias Inkfish.Subs
  alias Inkfish.Teams
  alias Inkfish.Grades.Grade

  def show(conn, %{"id" => id}) do
    sub = Subs.get_sub!(id)
    sub = %{sub | team: Teams.get_team!(sub.team_id)}
    sub_data = InkfishWeb.Staff.SubView.render("sub.json", sub: sub)

    autogrades = sub.grades
    |> Enum.filter(&(!is_nil(&1.log_uuid)))
    |> Enum.map(fn grade ->
      grade = %{grade | sub: sub}
      log = Grade.get_log(grade)
      token = Phoenix.Token.sign(conn, "autograde", %{uuid: grade.log_uuid})
      {grade, token, log}
    end)

    render(conn, "show.html", sub: sub, sub_data: sub_data, autogrades: autogrades)
  end

  def update(conn, %{"id" => _id, "sub" => params}) do
    # This can only set a sub active or ignore late penalty.
    sub = conn.assigns[:sub]

    if params["active"] do
      Subs.set_sub_active!(sub)
    end

    if params["ignore_late_penalty"] do
      Subs.update_sub_ignore_late(sub, params)
    end

    conn
    |> put_flash(:info, "Updated sub flags: ##{sub.id}.")
    |> redirect(to: Routes.staff_sub_path(conn, :show, sub))
  end
end
