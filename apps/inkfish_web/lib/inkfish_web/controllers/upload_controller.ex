defmodule InkfishWeb.UploadController do
  use InkfishWeb, :controller

  alias Inkfish.Uploads
  alias Inkfish.Uploads.Upload

  defp check_token(conn, params = %{"token" => token}) do
    case Phoenix.Token.verify(conn, "upload", token, max_age: 86400) do
      {:ok, %{kind: kind}} ->
        Map.put(params, "kind", kind)
      _else ->
        params
    end
  end
  defp check_token(_conn, params), do: params

  def create(conn, %{"upload" => upload_params}) do
    upload_params = check_token(conn, upload_params)

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
          name: upload.name,
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

 def show(conn, %{"id" => id, "show" => show}) do
    upload = Uploads.get_upload!(id)
    path = Upload.upload_path(upload)

    cond do
      show ->
        conn
        |> put_resp_header("content-type", "text/plain")
        |> put_resp_header("content-disposition", "inline")
        |> send_resp(200, File.read!(path))
      upload.kind == "user_photo" ->
        conn
        |> put_resp_header("content-type", "image/jpeg")
        |> put_resp_header("content-disposition", "inline")
        |> send_resp(200, File.read!(path))
      true ->
        conn
        |> put_resp_header("content-type", "application/octet-stream")
        |> put_resp_header("content-disposition", "attachment; filename=\"#{upload.name}\"")
        |> send_resp(200, File.read!(path))
    end
  end

  def show(conn, %{"id" => id}) do
    show(conn, %{"id" => id, "show" => false})
  end
 
  def download(conn, %{"id" => id, "name" => name}) do
    upload = Uploads.get_upload!(id)
    if name == upload.name do
      path = Upload.upload_path(upload)

      conn
      |> put_resp_header("content-type", "application/octet-stream")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{upload.name}\"")
      |> send_resp(200, File.read!(path))
    else
      conn
      |> redirect(to: Routes.upload_path(conn, :download, upload, upload.name))
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

  def unpacked(conn, %{"id" => id, "path" => parts}) do
    rel_path = parts
    |> Enum.join("/")
    |> :filename.safe_relative_path()

    if rel_path == :unsafe do
      conn
      |> put_resp_header("content-type", "text/plain")
      |> send_resp(500, "Bad path")
    else
      upload = Uploads.get_upload!(id)
      base = Upload.unpacked_path(upload)
      path = Path.join(base, rel_path)
      name = Path.basename(path)

      ctype = (
        if name =~ ~r/\.jpg/ do
          "image/jpeg"
        else
          "application/octet-stream"
        end
      )

      conn
      |> put_resp_header("content-type", ctype)
      |> put_resp_header("content-disposition", "attachment; filename=\"#{name}\"")
      |> send_resp(200, File.read!(path))
    end
  end
end
