defmodule InkfishWeb.AssignmentController do
  use InkfishWeb, :controller

  plug InkfishWeb.Plugs.FetchItem, [assignment: "id"]
    when action not in [:index, :new, :create]

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {:show, :course}

  alias Inkfish.Assignments

  def show(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment_for_student!(id, conn.assigns[:current_user])
    render(conn, "show.html", assignment: assignment)
  end
end
