defmodule InkfishWeb.SubControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    %{student: student, assignment: assignment, grade: grade} = stock_course()
    conn = login(conn, student.login)
    {:ok, conn: conn, grade: grade, assignment: assignment}
  end

  describe "new sub" do
    test "renders form", %{conn: conn, assignment: asg} do
      conn = get(conn, Routes.assignment_sub_path(conn, :new, asg))
      assert html_response(conn, 200) =~ "New Sub"
    end
  end

  describe "create sub" do
    test "redirects to show when data is valid", %{conn: conn, assignment: asg} do
      params = params_with_assocs(:sub, assignment: asg)
      conn = post(conn, Routes.assignment_sub_path(conn, :create, asg), sub: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.sub_path(conn, :show, id)

      conn = get(conn, Routes.sub_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Sub"
    end

    test "renders errors when data is invalid", %{conn: conn, assignment: asg} do
      params = %{}
      conn = post(conn, Routes.assignment_sub_path(conn, :create, asg), sub: params)
      assert html_response(conn, 200) =~ "New Sub"
    end
  end
end
