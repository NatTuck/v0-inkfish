defmodule InkfishWeb.BucketControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  describe "index" do
    setup [:create_cs101]

    test "lists all buckets", %{conn: conn, course: course} do
      conn = conn
      |> login("alice")
      |> get(Routes.staff_course_bucket_path(conn, :index, course))
      assert html_response(conn, 200) =~ "Listing Buckets"
    end
  end

  describe "new bucket" do
    setup [:create_cs101]

    test "renders form", %{conn: conn, course: course} do
      conn = conn
      |> login("bob")
      |> get(Routes.staff_course_bucket_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Bucket"
    end
  end

  describe "create bucket" do
    setup [:create_cs101]

    test "redirects to show when data is valid", %{conn: conn, course: course} do
      params = params_with_assocs(:bucket)
      conn = conn
      |> login("bob")
      |> post(Routes.staff_course_bucket_path(conn, :create, course), bucket: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :show, id)

      conn = get(conn, Routes.staff_bucket_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Bucket"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = conn
      |> login("bob")
      |> post(Routes.staff_course_bucket_path(conn, :create, course), bucket: %{})
      assert html_response(conn, 200) =~ "New Bucket"
    end
  end

  describe "edit bucket" do
    setup [:create_cs101]

    test "renders form for editing chosen bucket", %{conn: conn, bucket: bucket} do
      conn = conn
      |> login("bob")
      |> get(Routes.staff_bucket_path(conn, :edit, bucket))
      assert html_response(conn, 200) =~ "Edit Bucket"
    end
  end

  describe "update bucket" do
    setup [:create_cs101]

    test "redirects when data is valid", %{conn: conn, bucket: bucket} do
      params = %{"name" => "some updated name"}
      conn = conn
      |> login("bob")
      |> put(Routes.staff_bucket_path(conn, :update, bucket), bucket: params)
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :show, bucket)

      conn = get(conn, Routes.staff_bucket_path(conn, :show, bucket))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, bucket: bucket} do
      conn = conn
      |> login("bob")
      |> put(Routes.staff_bucket_path(conn, :update, bucket), bucket: %{"name" => "x"})
      assert html_response(conn, 200) =~ "Edit Bucket"
    end
  end

  describe "delete bucket" do
    setup [:create_cs101]

    test "deletes chosen bucket", %{conn: conn, bucket: bucket, course: course} do
      conn = conn
      |> login("bob")
      |> delete(Routes.staff_bucket_path(conn, :delete, bucket))
      assert redirected_to(conn) == Routes.staff_course_bucket_path(conn, :index, course)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_bucket_path(conn, :show, bucket))
      end
    end
  end

  defp create_cs101(_) do
    bob = Inkfish.Users.get_user_by_login!("bob")
    dave = Inkfish.Users.get_user_by_login!("dave")
    course = insert(:course, name: "CS101" )
    _bob_reg = insert(:reg, course: course,
      user: bob, is_prof: true)
    _dave_reg = insert(:reg, course: course,
      user: dave, is_student: true)

    bucket = insert(:bucket, course: course)
    {:ok, bucket: bucket, course: course}
  end
end
