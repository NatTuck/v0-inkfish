defmodule InkfishWeb.GradeControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Grades

  @create_attrs %{score: "120.5"}
  @update_attrs %{score: "456.7"}
  @invalid_attrs %{score: nil}

  def fixture(:grade) do
    {:ok, grade} = Grades.create_grade(@create_attrs)
    grade
  end

  describe "index" do
    test "lists all grades", %{conn: conn} do
      conn = get(conn, Routes.grade_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Grades"
    end
  end

  describe "new grade" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.grade_path(conn, :new))
      assert html_response(conn, 200) =~ "New Grade"
    end
  end

  describe "create grade" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.grade_path(conn, :create), grade: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.grade_path(conn, :show, id)

      conn = get(conn, Routes.grade_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Grade"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.grade_path(conn, :create), grade: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Grade"
    end
  end

  describe "edit grade" do
    setup [:create_grade]

    test "renders form for editing chosen grade", %{conn: conn, grade: grade} do
      conn = get(conn, Routes.grade_path(conn, :edit, grade))
      assert html_response(conn, 200) =~ "Edit Grade"
    end
  end

  describe "update grade" do
    setup [:create_grade]

    test "redirects when data is valid", %{conn: conn, grade: grade} do
      conn = put(conn, Routes.grade_path(conn, :update, grade), grade: @update_attrs)
      assert redirected_to(conn) == Routes.grade_path(conn, :show, grade)

      conn = get(conn, Routes.grade_path(conn, :show, grade))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, grade: grade} do
      conn = put(conn, Routes.grade_path(conn, :update, grade), grade: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Grade"
    end
  end

  describe "delete grade" do
    setup [:create_grade]

    test "deletes chosen grade", %{conn: conn, grade: grade} do
      conn = delete(conn, Routes.grade_path(conn, :delete, grade))
      assert redirected_to(conn) == Routes.grade_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.grade_path(conn, :show, grade))
      end
    end
  end

  defp create_grade(_) do
    grade = fixture(:grade)
    {:ok, grade: grade}
  end
end
