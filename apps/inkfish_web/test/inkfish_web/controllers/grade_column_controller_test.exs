defmodule InkfishWeb.GradeColumnControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Grades

  @create_attrs %{kind: "some kind", name: "some name", params: "some params", points: "120.5", weight: "120.5"}
  @update_attrs %{kind: "some updated kind", name: "some updated name", params: "some updated params", points: "456.7", weight: "456.7"}
  @invalid_attrs %{kind: nil, name: nil, params: nil, points: nil, weight: nil}

  def fixture(:grade_column) do
    {:ok, grade_column} = Grades.create_grade_column(@create_attrs)
    grade_column
  end

  describe "index" do
    test "lists all grade_columns", %{conn: conn} do
      conn = get(conn, Routes.grade_column_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Grade_Columns"
    end
  end

  describe "new grade_column" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.grade_column_path(conn, :new))
      assert html_response(conn, 200) =~ "New Grade_Column"
    end
  end

  describe "create grade_column" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.grade_column_path(conn, :create), grade_column: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.grade_column_path(conn, :show, id)

      conn = get(conn, Routes.grade_column_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Grade_Column"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.grade_column_path(conn, :create), grade_column: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Grade_Column"
    end
  end

  describe "edit grade_column" do
    setup [:create_grade_column]

    test "renders form for editing chosen grade_column", %{conn: conn, grade_column: grade_column} do
      conn = get(conn, Routes.grade_column_path(conn, :edit, grade_column))
      assert html_response(conn, 200) =~ "Edit Grade_Column"
    end
  end

  describe "update grade_column" do
    setup [:create_grade_column]

    test "redirects when data is valid", %{conn: conn, grade_column: grade_column} do
      conn = put(conn, Routes.grade_column_path(conn, :update, grade_column), grade_column: @update_attrs)
      assert redirected_to(conn) == Routes.grade_column_path(conn, :show, grade_column)

      conn = get(conn, Routes.grade_column_path(conn, :show, grade_column))
      assert html_response(conn, 200) =~ "some updated kind"
    end

    test "renders errors when data is invalid", %{conn: conn, grade_column: grade_column} do
      conn = put(conn, Routes.grade_column_path(conn, :update, grade_column), grade_column: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Grade_Column"
    end
  end

  describe "delete grade_column" do
    setup [:create_grade_column]

    test "deletes chosen grade_column", %{conn: conn, grade_column: grade_column} do
      conn = delete(conn, Routes.grade_column_path(conn, :delete, grade_column))
      assert redirected_to(conn) == Routes.grade_column_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.grade_column_path(conn, :show, grade_column))
      end
    end
  end

  defp create_grade_column(_) do
    grade_column = fixture(:grade_column)
    {:ok, grade_column: grade_column}
  end
end
