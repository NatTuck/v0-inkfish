defmodule InkfishWeb.Staff.SubControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Subs

  @create_attrs %{active: true, score: "120.5"}
  @update_attrs %{active: false, score: "456.7"}
  @invalid_attrs %{active: nil, score: nil}

  def fixture(:sub) do
    {:ok, sub} = Subs.create_sub(@create_attrs)
    sub
  end

  describe "index" do
    test "lists all subs", %{conn: conn} do
      conn = get(conn, Routes.staff_sub_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Subs"
    end
  end

  describe "new sub" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.staff_sub_path(conn, :new))
      assert html_response(conn, 200) =~ "New Sub"
    end
  end

  describe "create sub" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.staff_sub_path(conn, :create), sub: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_sub_path(conn, :show, id)

      conn = get(conn, Routes.staff_sub_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Sub"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.staff_sub_path(conn, :create), sub: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Sub"
    end
  end

  describe "edit sub" do
    setup [:create_sub]

    test "renders form for editing chosen sub", %{conn: conn, sub: sub} do
      conn = get(conn, Routes.staff_sub_path(conn, :edit, sub))
      assert html_response(conn, 200) =~ "Edit Sub"
    end
  end

  describe "update sub" do
    setup [:create_sub]

    test "redirects when data is valid", %{conn: conn, sub: sub} do
      conn = put(conn, Routes.staff_sub_path(conn, :update, sub), sub: @update_attrs)
      assert redirected_to(conn) == Routes.staff_sub_path(conn, :show, sub)

      conn = get(conn, Routes.staff_sub_path(conn, :show, sub))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, sub: sub} do
      conn = put(conn, Routes.staff_sub_path(conn, :update, sub), sub: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Sub"
    end
  end

  describe "delete sub" do
    setup [:create_sub]

    test "deletes chosen sub", %{conn: conn, sub: sub} do
      conn = delete(conn, Routes.staff_sub_path(conn, :delete, sub))
      assert redirected_to(conn) == Routes.staff_sub_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_sub_path(conn, :show, sub))
      end
    end
  end

  defp create_sub(_) do
    sub = fixture(:sub)
    {:ok, sub: sub}
  end
end
