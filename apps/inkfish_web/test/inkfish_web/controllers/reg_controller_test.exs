defmodule InkfishWeb.RegControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  alias Inkfish.Users

  describe "index" do
    setup [:create_reg]
    
    test "lists all regs", %{conn: conn, reg: reg} do
      conn = get(conn, Routes.course_reg_path(conn, :index, reg.course.id))
      assert html_response(conn, 200) =~ "Listing Regs"
    end
  end

  describe "new reg" do
    test "renders form", %{conn: conn} do
      course = insert(:course)
      conn = get(conn, Routes.course_reg_path(conn, :new, course.id))
      assert html_response(conn, 200) =~ "New Reg"
    end
  end

  describe "create reg" do
    test "redirects to show when data is valid", %{conn: conn} do
      course = insert(:course)
      user = insert(:user)
      conn = post(conn, Routes.course_reg_path(conn, course, :create), 
        reg: %{user_id: user.id, course_id: course.id})

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.reg_path(conn, :show, id)

      conn = get(conn, Routes.reg_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Reg"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      course = insert(:course)
      conn = post(conn, Routes.course_reg_path(conn, course, :create), reg: %{})
      assert html_response(conn, 200) =~ "New Reg"
    end
  end

  describe "edit reg" do
    setup [:create_reg]

    test "renders form for editing chosen reg", %{conn: conn, reg: reg} do
      conn = get(conn, Routes.reg_path(conn, :edit, reg))
      assert html_response(conn, 200) =~ "Edit Reg"
    end
  end

  describe "update reg" do
    setup [:create_reg]

    test "redirects when data is valid", %{conn: conn, reg: reg} do
      conn = put(conn, Routes.reg_path(conn, :update, reg), reg: %{is_student: true})
      assert redirected_to(conn) == Routes.reg_path(conn, :show, reg)

      conn = get(conn, Routes.reg_path(conn, :show, reg))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, reg: reg} do
      conn = put(conn, Routes.reg_path(conn, :update, reg), 
        reg: %{is_student: true, is_staff: true})
      assert html_response(conn, 200) =~ "Edit Reg"
    end
  end

  describe "delete reg" do
    setup [:create_reg]

    test "deletes chosen reg", %{conn: conn, reg: reg} do
      conn = delete(conn, Routes.reg_path(conn, :delete, reg))
      assert redirected_to(conn) == Routes.course_reg_path(conn, :index, reg.course.id)
      assert_error_sent 404, fn ->
        get(conn, Routes.reg_path(conn, :show, reg))
      end
    end
  end

  defp create_reg(_) do
    reg = insert(:reg)
    {:ok, reg: reg}
  end
end
