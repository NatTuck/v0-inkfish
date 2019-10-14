defmodule InkfishWeb.GradeController do
  use InkfishWeb, :controller

  alias Inkfish.Grades

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [grade: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg
  plug Plugs.RequireSubmitter
    when action in [:show]

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses", :course, :index}
  plug Breadcrumb, {:show, :course}
  plug Breadcrumb, {:show, :assignment}
  plug Breadcrumb, {:show, :sub}

  def show(conn, %{"id" => id}) do
    # Re-fetch grade for line comments.
    grade = Grades.get_grade!(id)

    if grade_hidden?(conn, conn.assigns[:assignment]) do
      conn
      |> put_flash(:error, "Grade not ready yet.")
      |> redirect(to: Routes.sub_path(conn, :show, conn.assigns[:sub]))
    else
      {id, _} = Integer.parse(id)
      grade_json = InkfishWeb.Staff.GradeView.render("grade.json", %{grade: grade})
      data = Inkfish.Subs.read_sub_data(grade.sub_id)
      |> Map.put(:edit, false)
      |> Map.put(:grade_id, id)
      |> Map.put(:grade, grade_json)
      render(conn, "show.html", grade: grade, data: data)
    end
  end
end
