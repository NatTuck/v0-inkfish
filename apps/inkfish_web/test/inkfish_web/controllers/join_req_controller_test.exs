defmodule InkfishWeb.JoinReqControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  def fixture(:join_req) do
    insert(:join_req)
  end

  defp create_stock_course(_) do
    %{course: course} = stock_course()
    {:ok, course: course}
  end

  describe "new join_req" do
    setup [:create_stock_course]

    test "renders form", %{conn: conn, course: course} do
      conn = conn
      |> login("erin")
      |> get(Routes.course_join_req_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Joinreq"
    end
  end

  describe "create join_req" do
    setup [:create_stock_course]

    test "redirects to root when data is valid", %{conn: conn, course: course} do
      params = params_for(:join_req)
      conn = conn
      |> login("erin")
      |> post(Routes.course_join_req_path(conn, :create, course), join_req: params)
      assert redirected_to(conn) == Routes.course_path(conn, :index)
    end
  end
end
