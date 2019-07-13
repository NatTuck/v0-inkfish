defmodule InkfishWeb.AssignmentController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [assignment: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {:show, :course}

  alias Inkfish.Assignments

  def show(conn, %{"id" => id}) do
    subs = Assignments.list_subs_for_reg(id, conn.assigns[:current_reg])
    render(conn, "show.html", subs: subs)
  end
end
