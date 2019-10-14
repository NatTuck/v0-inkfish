defmodule InkfishWeb.Staff.AssignmentControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  def fixture(:assignment) do
    insert(:assignment)
  end

  defp create_assignment(_) do
    assignment = fixture(:assignment)
    {:ok, assignment: assignment}
  end

  defp create_stock_course(_) do
    %{course: course, bucket: bucket, staff: staff} = stock_course()
    {:ok, course: course, bucket: bucket, staff: staff}
  end

  describe "new assignment" do
    setup [:create_stock_course]

    test "renders form", %{conn: conn, staff: staff, bucket: bucket} do
      conn = conn
      |> login(staff.login)
      |> get(Routes.staff_bucket_assignment_path(conn, :new, bucket))
      assert html_response(conn, 200) =~ "New Assignment"
    end
  end

  describe "create assignment" do
    setup [:create_stock_course]

    test "redirects to show when data is valid", %{conn: conn, staff: staff, bucket: bucket} do
      params = params_with_assocs(:assignment, bucket: bucket)

      conn = conn
      |> login(staff.login)
      |> post(Routes.staff_bucket_assignment_path(conn, :create, bucket), assignment: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_assignment_path(conn, :show, id)

      conn = get(conn, Routes.staff_assignment_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Assignment"
    end

    test "renders errors when data is invalid", %{conn: conn, bucket: bucket, staff: staff} do
      params = %{bucket_id: -1, name: ""}

      conn = conn
      |> login(staff.login)
      |> post(Routes.staff_bucket_assignment_path(conn, :create, bucket), assignment: params)
      assert html_response(conn, 200) =~ "New Assignment"
    end
  end

  describe "edit assignment" do
    setup [:create_assignment]

    test "renders form for editing chosen assignment", %{conn: conn, assignment: assignment} do
      conn = conn
      |> login("alice")
      |> get(Routes.staff_assignment_path(conn, :edit, assignment))
      assert html_response(conn, 200) =~ "Edit Assignment"
    end
  end

  describe "update assignment" do
    setup [:create_assignment]

    test "redirects when data is valid", %{conn: conn, assignment: assignment} do
      params = %{name: "Assignment #z"}

      conn = conn
      |> login("alice")
      |> put(Routes.staff_assignment_path(conn, :update, assignment), assignment: params)
      assert redirected_to(conn) == Routes.staff_assignment_path(conn, :show, assignment)

      conn = get(conn, Routes.staff_assignment_path(conn, :show, assignment))
      assert html_response(conn, 200) =~ "Assignment #z"
    end

    test "renders errors when data is invalid", %{conn: conn, assignment: assignment} do
      params = %{bucket_id: -1, name: ""}

      conn = conn
      |> login("alice")
      |> put(Routes.staff_assignment_path(conn, :update, assignment), assignment: params)
      assert html_response(conn, 200) =~ "Edit Assignment"
    end
  end

  describe "delete assignment" do
    setup [:create_assignment]

    test "deletes chosen assignment", %{conn: conn, assignment: assignment} do
      conn = conn
      |> login("alice")
      |> delete(Routes.staff_assignment_path(conn, :delete, assignment))
      assert redirected_to(conn) == Routes.staff_course_path(conn, :show, conn.assigns[:course])
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_assignment_path(conn, :show, assignment))
      end
    end
  end
end
