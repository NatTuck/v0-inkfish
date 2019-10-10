defmodule InkfishWeb.Staff.TeamsetControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    course = insert(:course)
    staff = insert(:user)
    _sr = insert(:reg, course: course, user: staff, is_staff: true)
    teamset = insert(:teamset, course: course)
    conn = login(conn, staff.login)
    {:ok, conn: conn, course: course, teamset: teamset, staff: staff}
  end

  describe "index" do
    test "lists all teamsets", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_teamset_path(conn, :index, course))
      assert html_response(conn, 200) =~ "Listing Teamsets"
    end
  end

  describe "new teamset" do
    test "renders form", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_teamset_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Teamset"
    end
  end

  describe "create teamset" do
    test "redirects to show when data is valid", %{conn: conn, course: course} do
      params = params_for(:teamset, course: course)
      conn = post(conn, Routes.staff_course_teamset_path(conn, :create, course),
        teamset: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_teamset_path(conn, :show, id)

      conn = get(conn, Routes.staff_teamset_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Teamset"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      params = %{name: ""}
      conn = post(conn, Routes.staff_course_teamset_path(conn, :create, course),
        teamset: params)
      assert html_response(conn, 200) =~ "New Teamset"
    end
  end

  describe "edit teamset" do
    test "renders form for editing chosen teamset", %{conn: conn, teamset: teamset} do
      conn = get(conn, Routes.staff_teamset_path(conn, :edit, teamset))
      assert html_response(conn, 200) =~ "Edit Teamset"
    end
  end

  describe "update teamset" do
    test "redirects when data is valid", %{conn: conn, teamset: teamset} do
      params = %{name: "new name"}
      conn = put(conn, Routes.staff_teamset_path(conn, :update, teamset),
        teamset: params)
      assert redirected_to(conn) == Routes.staff_teamset_path(conn, :show, teamset)

      conn = get(conn, Routes.staff_teamset_path(conn, :show, teamset))
      assert html_response(conn, 200) =~ "new name"
    end

    test "renders errors when data is invalid", %{conn: conn, teamset: teamset} do
      params = %{name: ""}
      conn = put(conn, Routes.staff_teamset_path(conn, :update, teamset),
        teamset: params)
      assert html_response(conn, 200) =~ "Edit Teamset"
    end
  end

  describe "delete teamset" do
    test "deletes chosen teamset", %{conn: conn, teamset: teamset} do
      conn = delete(conn, Routes.staff_teamset_path(conn, :delete, teamset))
      assert redirected_to(conn) == Routes.staff_course_teamset_path(
        conn, :index, teamset.course_id)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_teamset_path(conn, :show, teamset))
      end
    end
  end
end
