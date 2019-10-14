defmodule InkfishWeb.Staff.SubControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    %{staff: staff, assignment: assignment, sub: sub} = stock_course()
    conn = login(conn, staff.login)
    {:ok, conn: conn, staff: staff, assignment: assignment, sub: sub}
  end

  describe "show sub" do
    test "shows a sub", %{conn: conn, sub: sub} do
      conn = get(conn, Routes.staff_sub_path(conn, :show, sub))
      assert html_response(conn, 200) =~ "Show Sub"
    end
  end

  describe "update sub" do
    test "redirects when data is valid", %{conn: conn, sub: sub} do
      params = %{ignore_late_penalty: true}
      conn = put(conn, Routes.staff_sub_path(conn, :update, sub), sub: params)
      assert redirected_to(conn) == Routes.staff_sub_path(conn, :show, sub)

      conn = get(conn, Routes.staff_sub_path(conn, :show, sub))
      assert html_response(conn, 200)
    end
  end
end
