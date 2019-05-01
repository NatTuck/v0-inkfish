defmodule InkfishWeb.RegControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Users

  @create_attrs %{is_grader: true, is_prof: true, is_staff: true, is_student: true}
  @update_attrs %{is_grader: false, is_prof: false, is_staff: false, is_student: false}
  @invalid_attrs %{is_grader: nil, is_prof: nil, is_staff: nil, is_student: nil}

  def fixture(:reg) do
    {:ok, reg} = Users.create_reg(@create_attrs)
    reg
  end

  describe "index" do
    test "lists all regs", %{conn: conn} do
      conn = get(conn, Routes.reg_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Regs"
    end
  end

  describe "new reg" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.reg_path(conn, :new))
      assert html_response(conn, 200) =~ "New Reg"
    end
  end

  describe "create reg" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.reg_path(conn, :create), reg: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.reg_path(conn, :show, id)

      conn = get(conn, Routes.reg_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Reg"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.reg_path(conn, :create), reg: @invalid_attrs)
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
      conn = put(conn, Routes.reg_path(conn, :update, reg), reg: @update_attrs)
      assert redirected_to(conn) == Routes.reg_path(conn, :show, reg)

      conn = get(conn, Routes.reg_path(conn, :show, reg))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, reg: reg} do
      conn = put(conn, Routes.reg_path(conn, :update, reg), reg: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Reg"
    end
  end

  describe "delete reg" do
    setup [:create_reg]

    test "deletes chosen reg", %{conn: conn, reg: reg} do
      conn = delete(conn, Routes.reg_path(conn, :delete, reg))
      assert redirected_to(conn) == Routes.reg_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.reg_path(conn, :show, reg))
      end
    end
  end

  defp create_reg(_) do
    reg = fixture(:reg)
    {:ok, reg: reg}
  end
end
