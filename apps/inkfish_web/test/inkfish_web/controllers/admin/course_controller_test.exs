defmodule InkfishWeb.Admin.CourseControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  def fixture(:course) do
    insert(:course)
  end

  describe "index" do
    test "lists all courses", %{conn: conn} do
      conn = conn
      |> login("alice")
      |> get(Routes.admin_course_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Courses"
    end
  end

  describe "new course" do
    test "renders form", %{conn: conn} do
      conn = conn
      |> login("alice")
      |> get(Routes.admin_course_path(conn, :new))
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "create course" do
    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:course)

      conn = conn
      |> login("alice")
      |> post(Routes.admin_course_path(conn, :create), course: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_course_path(conn, :show, id)

      conn = get(conn, Routes.admin_course_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Course"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      params = %{name: "", solo_teamset_id: -1}

      conn = conn
      |> login("alice")
      |> post( Routes.admin_course_path(conn, :create), course: params)

      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "edit course" do
    setup [:create_course]

    test "renders form for editing chosen course", %{conn: conn, course: course} do
      conn = conn
      |> login("alice")
      |> get(Routes.admin_course_path(conn, :edit, course))
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "update course" do
    setup [:create_course]

    test "redirects when data is valid", %{conn: conn, course: course} do
      params = %{"name" => "Updated course"}

      conn = conn
      |> login("alice")
      |> put(Routes.admin_course_path(conn, :update, course), course: params)
      assert redirected_to(conn) == Routes.admin_course_path(conn, :show, course)

      conn = get(conn, Routes.admin_course_path(conn, :show, course))
      assert html_response(conn, 200) =~ "Updated course"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      params = %{name: "", solo_teamset_id: -1}

      conn = conn
      |> login("alice")
      |> put(Routes.admin_course_path(conn, :update, course), course: params)
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "delete course" do
    setup [:create_course]

    test "deletes chosen course", %{conn: conn, course: course} do
      conn = conn
      |> login("alice")
      |> delete(Routes.admin_course_path(conn, :delete, course))
      assert redirected_to(conn) == Routes.admin_course_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.admin_course_path(conn, :show, course))
      end
    end
  end

  defp create_course(_) do
    course = fixture(:course)
    {:ok, course: course}
  end
end
