defmodule InkfishWeb.Staff.BucketControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Courses

  @create_attrs %{name: "some name", weight: "120.5"}
  @update_attrs %{name: "some updated name", weight: "456.7"}
  @invalid_attrs %{name: nil, weight: nil}

  def fixture(:bucket) do
    {:ok, bucket} = Courses.create_bucket(@create_attrs)
    bucket
  end

  describe "index" do
    test "lists all buckets", %{conn: conn} do
      conn = get(conn, Routes.staff_bucket_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Buckets"
    end
  end

  describe "new bucket" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.staff_bucket_path(conn, :new))
      assert html_response(conn, 200) =~ "New Bucket"
    end
  end

  describe "create bucket" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.staff_bucket_path(conn, :create), bucket: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :show, id)

      conn = get(conn, Routes.staff_bucket_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Bucket"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.staff_bucket_path(conn, :create), bucket: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Bucket"
    end
  end

  describe "edit bucket" do
    setup [:create_bucket]

    test "renders form for editing chosen bucket", %{conn: conn, bucket: bucket} do
      conn = get(conn, Routes.staff_bucket_path(conn, :edit, bucket))
      assert html_response(conn, 200) =~ "Edit Bucket"
    end
  end

  describe "update bucket" do
    setup [:create_bucket]

    test "redirects when data is valid", %{conn: conn, bucket: bucket} do
      conn = put(conn, Routes.staff_bucket_path(conn, :update, bucket), bucket: @update_attrs)
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :show, bucket)

      conn = get(conn, Routes.staff_bucket_path(conn, :show, bucket))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, bucket: bucket} do
      conn = put(conn, Routes.staff_bucket_path(conn, :update, bucket), bucket: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Bucket"
    end
  end

  describe "delete bucket" do
    setup [:create_bucket]

    test "deletes chosen bucket", %{conn: conn, bucket: bucket} do
      conn = delete(conn, Routes.staff_bucket_path(conn, :delete, bucket))
      assert redirected_to(conn) == Routes.staff_bucket_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_bucket_path(conn, :show, bucket))
      end
    end
  end

  defp create_bucket(_) do
    bucket = fixture(:bucket)
    {:ok, bucket: bucket}
  end
end
