defmodule InkfishWeb.Staff.GradeControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    %{staff: staff, sub: sub, grade: grade} = stock_course()
    conn = login(conn, staff.login)
    {:ok, conn: conn, staff: staff, sub: sub, grade: grade}
  end

  describe "show grade" do
    test "shows grade", %{conn: conn, grade: grade} do
      conn = get(conn, Routes.staff_grade_path(conn, :show, grade))
      assert html_response(conn, 200) =~ "Show Grade"
    end
  end

  describe "create grade" do
    test "redirects to show when data is valid", %{conn: conn, sub: sub} do
      params = params_with_assocs(:grade)
      conn = post(conn, Routes.staff_sub_grade_path(conn, :create, sub), grade: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_grade_path(conn, :edit, id)

      conn = get(conn, Routes.staff_grade_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Grade"
    end

    test "fails when data is invalid", %{conn: conn, sub: sub} do
      params = %{grade_column_id: nil}
      conn = post(conn, Routes.staff_sub_grade_path(conn, :create, sub), grade: params)
      assert get_flash(conn, :error) =~ "Failed to create grade"
    end
  end

  describe "edit grade" do
    test "renders form for editing chosen grade", %{conn: conn, grade: grade} do
      conn = get(conn, Routes.staff_grade_path(conn, :edit, grade))
      assert html_response(conn, 200) =~ "Edit Grade"
    end
  end
end
