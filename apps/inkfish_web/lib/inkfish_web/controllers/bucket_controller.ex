defmodule InkfishWeb.BucketController do
  use InkfishWeb, :controller

  alias Inkfish.Courses
  alias Inkfish.Courses.Bucket

  def index(conn, _params) do
    buckets = Courses.list_buckets()
    render(conn, "index.html", buckets: buckets)
  end

  def new(conn, _params) do
    changeset = Courses.change_bucket(%Bucket{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"bucket" => bucket_params}) do
    case Courses.create_bucket(bucket_params) do
      {:ok, bucket} ->
        conn
        |> put_flash(:info, "Bucket created successfully.")
        |> redirect(to: Routes.bucket_path(conn, :show, bucket))

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
        |> redirect(to: Routes.bucket_path(conn, :show, bucket))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", bucket: bucket, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bucket = Courses.get_bucket!(id)
    {:ok, _bucket} = Courses.delete_bucket(bucket)

    conn
    |> put_flash(:info, "Bucket deleted successfully.")
    |> redirect(to: Routes.bucket_path(conn, :index))
  end
end
