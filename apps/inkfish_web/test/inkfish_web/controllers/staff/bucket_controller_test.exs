defmodule InkfishWeb.Staff.BucketControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  setup %{conn: conn} do
    course = insert(:course)
    staff = insert(:user)
    _sr = insert(:reg, course: course, user: staff, is_staff: true)
    bucket = insert(:bucket, course: course)
    conn = login(conn, staff.login)
    {:ok, conn: conn, course: course, bucket: bucket, staff: staff}
  end

  describe "index" do
    test "lists all buckets", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_bucket_path(conn, :index, course))
      assert html_response(conn, 200) =~ "Listing Buckets"
    end
  end

  describe "new bucket" do
    test "renders form", %{conn: conn, course: course} do
      conn = get(conn, Routes.staff_course_bucket_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Bucket"
    end
  end

  describe "create bucket" do
    test "redirects to show when data is valid", %{conn: conn, course: course} do
      params = params_for(:bucket)
      conn = post(conn, Routes.staff_course_bucket_path(conn, :create, course), bucket: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :show, id)

      conn = get(conn, Routes.staff_bucket_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Bucket"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      params = %{name: ""}
      conn = post(conn, Routes.staff_course_bucket_path(conn, :create, course), bucket: params)
      assert html_response(conn, 200) =~ "New Bucket"
    end
  end

  describe "edit bucket" do
    test "renders form for editing chosen bucket", %{conn: conn, bucket: bucket} do
      conn = get(conn, Routes.staff_bucket_path(conn, :edit, bucket))
      assert html_response(conn, 200) =~ "Edit Bucket"
    end
  end

  describe "update bucket" do
    test "redirects when data is valid", %{conn: conn, bucket: bucket} do
      params = %{name: "some updated name"}
      conn = put(conn, Routes.staff_bucket_path(conn, :update, bucket), bucket: params)
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :show, bucket)

      conn = get(conn, Routes.staff_bucket_path(conn, :show, bucket))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, bucket: bucket} do
      params = %{name: ""}
      conn = put(conn, Routes.staff_bucket_path(conn, :update, bucket), bucket: params)
      assert html_response(conn, 200) =~ "Edit Bucket"
    end
  end

  describe "delete bucket" do
    test "deletes chosen bucket", %{conn: conn, bucket: bucket} do
      conn = delete(conn, Routes.staff_bucket_path(conn, :delete, bucket))
      assert redirected_to(conn) == Routes.staff_course_bucket_path(conn, :index, bucket.course_id)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_bucket_path(conn, :show, bucket))
      end
    end
  end
end
