defmodule InkfishWeb.GraderController do
  use InkfishWeb, :controller

  alias Inkfish.Grades
  alias Inkfish.Grades.Grader

  def show(conn, %{"id" => id}) do
    grader = Grades.get_grader!(id)
    render(conn, "show.html", grader: grader)
  end
end
