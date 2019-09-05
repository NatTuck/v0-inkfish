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
  alias Inkfish.Subs.Sub
  alias Inkfish.Teams

  def show(conn, %{"id" => id}) do
    sub = Subs.get_sub!(id)
    sub = %{sub | team: Teams.get_team!(sub.team_id)}
    render(conn, "show.html", sub: sub)
  end

  def update(conn, %{"id" => id, "sub" => params}) do
    # This can only set a sub active.
    sub = conn.assigns[:sub]

    if params["active"] do
      Subs.set_sub_active!(sub)
    end

    conn
    |> put_flash(:info, "Set sub active: ##{sub.id}.")
    |> redirect(to: Routes.staff_reg_path(conn, :show, sub.reg_id))
  end
end
