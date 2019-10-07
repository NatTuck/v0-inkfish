defmodule InkfishWeb.GradeControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  defp create_grade(_) do
    due = Inkfish.LocalTime.in_days(-7)
    asgn = insert(:assignment, due: due)
    sub = insert(:sub, assignment: asgn)
    grade = insert(:grade, sub: sub)
    {:ok, grade: grade}
  end

  describe "show grade" do
    setup [:create_grade]

    test "show chosen grade", %{conn: conn, grade: grade} do
      conn = conn
      |> login("alice")
      |> get(Routes.grade_path(conn, :show, grade))
      assert html_response(conn, 200) =~ "Show Grade"
    end
  end
end
