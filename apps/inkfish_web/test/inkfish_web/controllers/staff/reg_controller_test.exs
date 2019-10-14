defmodule InkfishWeb.Staff.RegControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    course = insert(:course)
    staff = insert(:user)
    _sr = insert(:reg, course: course, user: staff, is_staff: true)
    reg = insert(:reg, course: course)
    conn = login(conn, staff.login)
    {:ok, conn: conn, course: course, reg: reg, staff: staff}
  end

  describe "index" do
    test "lists all regs", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_reg_path(conn, :index, course))
      assert html_response(conn, 200) =~ "Listing Regs"
    end
  end

  describe "new reg" do
    test "renders form", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_reg_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Reg"
    end
  end

  describe "create reg" do
    test "redirects to show when data is valid", %{conn: conn, course: course} do
      params = params_with_assocs(:reg)
      conn = post(conn, Routes.staff_course_reg_path(conn, :create, course), reg: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_reg_path(conn, :show, id)

      conn = get(conn, Routes.staff_reg_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Reg"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      params = %{is_student: true, is_staff: true}

      conn = post(conn, Routes.staff_course_reg_path(conn, :create, course), reg: params)
      assert html_response(conn, 200) =~ "New Reg"
    end
  end

  describe "edit reg" do
    test "renders form for editing chosen reg", %{conn: conn, reg: reg} do
      conn = get(conn, Routes.staff_reg_path(conn, :edit, reg))
      assert html_response(conn, 200) =~ "Edit Reg"
    end
  end

  describe "update reg" do
    test "redirects when data is valid", %{conn: conn, reg: reg} do
      params = %{is_student: false, is_staff: true}
      conn = put(conn, Routes.staff_reg_path(conn, :update, reg), reg: params)
      assert redirected_to(conn) == Routes.staff_reg_path(conn, :show, reg)

      conn = get(conn, Routes.staff_reg_path(conn, :show, reg))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, reg: reg} do
      params = %{is_student: true, is_staff: true}
      conn = put(conn, Routes.staff_reg_path(conn, :update, reg), reg: params)
      assert html_response(conn, 200) =~ "Edit Reg"
    end
  end

  describe "delete reg" do
    test "deletes chosen reg", %{conn: conn, reg: reg} do
      conn = delete(conn, Routes.staff_reg_path(conn, :delete, reg))
      assert redirected_to(conn) == Routes.staff_course_reg_path(conn, :index, reg.course_id)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_reg_path(conn, :show, reg))
      end
    end
  end
end
