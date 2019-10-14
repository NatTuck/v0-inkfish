defmodule InkfishWeb.Staff.JoinReqControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    %{staff: staff, course: course} = stock_course()
    user = insert(:user)
    jr = insert(:join_req, course: course, user: user)
    conn = login(conn, staff.login)
    {:ok, conn: conn, course: course, user: user, join_req: jr}
  end

  describe "index" do
    test "lists all join_reqs", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_join_req_path(conn, :index, course))
      assert html_response(conn, 200) =~ "Listing Join Requests"
    end
  end

  describe "delete join_req" do
    test "deletes chosen join_req", %{conn: conn, join_req: join_req} do
      conn = delete(conn, Routes.staff_join_req_path(conn, :delete, join_req))
      assert redirected_to(conn) == Routes.staff_course_join_req_path(
        conn, :index, join_req.course_id)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_join_req_path(conn, :show, join_req))
      end
    end
  end
end
