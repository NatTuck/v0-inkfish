defmodule InkfishWeb.AssignmentController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [assignment: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {:show, :course}

  alias Inkfish.Assignments
  alias Inkfish.Teams

  def show(conn, %{"id" => id}) do
    reg  = conn.assigns[:current_reg]
    asg  = conn.assigns[:assignment]
    subs = Assignments.list_subs_for_reg(id, reg)
    team = Teams.get_active_team(asg, reg)
    render(conn, "show.html", subs: subs, team: team)
  end
end
