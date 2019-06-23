defmodule Inkfish.Uploads.Photo do

  alias Inkfish.Uploads.Upload

  def photo_path(upload) do
    Upload.upload_path(upload)
  end

  def thumb_path(upload) do
    thumb_path(upload.id, upload.name)
  end

  def thumb_path(id, name) do
    path = Upload.upload_path(id, name)
    if (path =~ ~r{\.jpg$}) do
      String.replace(path, ~r/\.jpg$/i, "_thumb.jpg")
    else
      String.replace(path, ~r/$/, "_thumb.jpg")
    end
  end

  def resize_photo!(from_path, to_path, width, height) do
    IO.inspect {:resize, from_path, to_path}
    {:ok, _} = from_path
    |> Gmex.open()
    |> Gmex.resize(width: width, height: height)
    |> Gmex.save(to_path)
  end
end
