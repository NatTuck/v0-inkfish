defmodule InkfishWeb.Staff.CourseControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Courses

  @create_attrs %{footer: "some footer", name: "some name", start_date: ~D[2010-04-17]}
  @update_attrs %{footer: "some updated footer", name: "some updated name", start_date: ~D[2011-05-18]}
  @invalid_attrs %{footer: nil, name: nil, start_date: nil}

  def fixture(:course) do
    {:ok, course} = Courses.create_course(@create_attrs)
    course
  end

  describe "index" do
    test "lists all courses", %{conn: conn} do
      conn = get(conn, Routes.staff_course_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Courses"
    end
  end

  describe "new course" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.staff_course_path(conn, :new))
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "gradesheet" do
    setup [:create_course]

    test "renders", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_path(conn, :gradesheet, course))
      assert html_response(conn, 200) =~ "Gradesheet"
    end
  end

  describe "create course" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.staff_course_path(conn, :create), course: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_course_path(conn, :show, id)

      conn = get(conn, Routes.staff_course_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Course"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.staff_course_path(conn, :create), course: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "edit course" do
    setup [:create_course]

    test "renders form for editing chosen course", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_path(conn, :edit, course))
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "update course" do
    setup [:create_course]

    test "redirects when data is valid", %{conn: conn, course: course} do
      conn = put(conn, Routes.staff_course_path(conn, :update, course), course: @update_attrs)
      assert redirected_to(conn) == Routes.staff_course_path(conn, :show, course)

      conn = get(conn, Routes.staff_course_path(conn, :show, course))
      assert html_response(conn, 200) =~ "some updated footer"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = put(conn, Routes.staff_course_path(conn, :update, course), course: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "delete course" do
    setup [:create_course]

    test "deletes chosen course", %{conn: conn, course: course} do
      conn = delete(conn, Routes.staff_course_path(conn, :delete, course))
      assert redirected_to(conn) == Routes.staff_course_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_course_path(conn, :show, course))
      end
    end
  end

  defp create_course(_) do
    course = fixture(:course)
    {:ok, course: course}
  end
end
