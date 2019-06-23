defmodule InkfishWeb.UploadController do
  use InkfishWeb, :controller

  alias Inkfish.Uploads
  alias Inkfish.Uploads.Upload

  def create(conn, %{"upload" => upload_params}) do
    upload_params = Map.put(upload_params, "user_id", conn.assigns[:current_user].id)
    mode = conn.assigns[:client_mode]
    case {mode, Uploads.create_upload(upload_params)} do
      {:browser, {:ok, upload}} ->
        conn
        |> put_flash(:info, "Upload created successfully.")
        |> redirect(to: Routes.admin_upload_path(conn, :show, upload))

      {:browser, {:error, %Ecto.Changeset{} = changeset}} ->
        render(conn, "new.html", changeset: changeset)

      {:ajax, {:ok, upload}} ->
        resp = %{
          status: "created",
          kind: upload.kind,
          path: Routes.upload_path(conn, :show, upload),
          id: upload.id,
        }
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(201, Jason.encode!(resp))

      {:ajax, {:error, %Ecto.Changeset{} = changeset}} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(500, Jason.encode!(%{error: inspect(changeset.errors)}))
    end
  end

  def show(conn, %{"id" => id}) do
    upload = Uploads.get_upload!(id)
    path = Upload.upload_path(upload)

    case upload.kind do
      "user_photo" ->
        conn
        |> put_resp_header("content-type", "image/jpeg")
        |> put_resp_header("content-disposition", "inline")
        |> send_resp(200, File.read!(path))
      _ ->
        conn
        |> put_resp_header("content-type", "application/octet-stream")
        |> put_resp_header("content-disposition", "attachment; filename=\"#{upload.name}\"")
        |> send_resp(200, File.read!(path))
    end
  end

  def thumb(conn, %{"id" => id}) do
    upload = Uploads.get_upload!(id)
    path = Uploads.Photo.thumb_path(upload)

    case upload.kind do
      "user_photo" ->
        conn
        |> put_resp_header("content-type", "image/jpeg")
        |> put_resp_header("content-disposition", "inline")
        |> send_resp(200, File.read!(path))
      _ ->
        conn
        |> put_resp_header("content-type", "text/plain")
        |> send_resp(500, "Not a photo, no thumbnail.")
    end
  end
end
