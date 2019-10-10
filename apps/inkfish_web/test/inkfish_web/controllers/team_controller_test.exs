defmodule InkfishWeb.TeamControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    %{course: course, student: student, team: team} = stock_course()
    conn = login(conn, student.login)
    {:ok, conn: conn, team: team, course: course}
  end

  describe "show" do
    test "shows a team", %{conn: conn, team: team} do
      conn = get(conn, Routes.team_path(conn, :show, team))
      assert html_response(conn, 200) =~ "Show Team"
    end
  end
end
