defmodule InkfishWeb.Staff.BucketController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug Plugs.FetchItem, [bucket: "id"]
    when action not in [:index, :new, :create]

  plug Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {"Buckets", :staff_course_bucket, :index, :course}
    when action not in [:index, :new, :create]

  alias Inkfish.Courses
  alias Inkfish.Courses.Bucket

  def index(conn, %{"course_id" => course_id}) do
    conn = assign(conn, :page_title, "List Buckets")
    buckets = Courses.list_buckets(course_id)
    render(conn, "index.html", buckets: buckets)
  end

  def new(conn, %{"course_id" => course_id}) do
    defaults = %Bucket{
      course_id: course_id,
      weight: 100,
    }
    changeset = Courses.change_bucket(defaults)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course_id" => course_id, "bucket" => bucket_params}) do
    bucket_params = Map.put(bucket_params, "course_id", course_id)

    case Courses.create_bucket(bucket_params) do
      {:ok, bucket} ->
        conn
        |> put_flash(:info, "Bucket created successfully.")
        |> redirect(to: Routes.staff_bucket_path(conn, :show, bucket))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    bucket = Courses.get_bucket!(id)
    render(conn, "show.html", bucket: bucket)
  end

  def edit(conn, %{"id" => id}) do
    bucket = Courses.get_bucket!(id)
    changeset = Courses.change_bucket(bucket)
    render(conn, "edit.html", bucket: bucket, changeset: changeset)
  end

  def update(conn, %{"id" => id, "bucket" => bucket_params}) do
    bucket = Courses.get_bucket!(id)

    case Courses.update_bucket(bucket, bucket_params) do
      {:ok, bucket} ->
        conn
        |> put_flash(:info, "Bucket updated successfully.")
        |> redirect(to: Routes.staff_bucket_path(conn, :show, bucket))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", bucket: bucket, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bucket = Courses.get_bucket!(id)
    {:ok, _bucket} = Courses.delete_bucket(bucket)

    conn
    |> put_flash(:info, "Bucket deleted successfully.")
    |> redirect(to: Routes.staff_course_bucket_path(conn, :index, bucket.course_id))
  end
end
