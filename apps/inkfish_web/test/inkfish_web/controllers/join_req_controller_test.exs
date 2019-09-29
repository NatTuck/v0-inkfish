defmodule InkfishWeb.JoinReqControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  alias Inkfish.JoinReqs

  def fixture(:join_req) do
    insert(:join_req)
  end

  describe "index" do
    test "lists all join_reqs", %{conn: conn, course: course} do
      conn = conn
      |> login("bob")
      |> get(Routes.staff_course_join_req_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Join reqs"
    end
  end

  describe "new join_req" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.join_req_path(conn, :new))
      assert html_response(conn, 200) =~ "New Join req"
    end
  end

  describe "create join_req" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.join_req_path(conn, :create), join_req: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.join_req_path(conn, :show, id)

      conn = get(conn, Routes.join_req_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Join req"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.join_req_path(conn, :create), join_req: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Join req"
    end
  end

  describe "edit join_req" do
    setup [:create_join_req]

    test "renders form for editing chosen join_req", %{conn: conn, join_req: join_req} do
      conn = get(conn, Routes.join_req_path(conn, :edit, join_req))
      assert html_response(conn, 200) =~ "Edit Join req"
    end
  end

  describe "update join_req" do
    setup [:create_join_req]

    test "redirects when data is valid", %{conn: conn, join_req: join_req} do
      conn = put(conn, Routes.join_req_path(conn, :update, join_req), join_req: @update_attrs)
      assert redirected_to(conn) == Routes.join_req_path(conn, :show, join_req)

      conn = get(conn, Routes.join_req_path(conn, :show, join_req))
      assert html_response(conn, 200) =~ "some updated login"
    end

    test "renders errors when data is invalid", %{conn: conn, join_req: join_req} do
      conn = put(conn, Routes.join_req_path(conn, :update, join_req), join_req: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Join req"
    end
  end

  describe "delete join_req" do
    setup [:create_join_req]

    test "deletes chosen join_req", %{conn: conn, join_req: join_req} do
      conn = delete(conn, Routes.join_req_path(conn, :delete, join_req))
      assert redirected_to(conn) == Routes.join_req_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.join_req_path(conn, :show, join_req))
      end
    end
  end

  defp create_join_req(_) do
    join_req = fixture(:join_req)
    {:ok, join_req: join_req}
  end
end
