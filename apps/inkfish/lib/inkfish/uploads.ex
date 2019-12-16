defmodule Inkfish.Uploads do
  @moduledoc """
  The Uploads context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Uploads.Upload

  @doc """
  Returns the list of uploads.

  ## Examples

      iex> list_uploads()
      [%Upload{}, ...]

  """
  def list_uploads do
    Repo.all(Upload)
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single upload.

  Raises `Ecto.NoResultsError` if the Upload does not exist.

  ## Examples

      iex> get_upload!(123)
      %Upload{}

      iex> get_upload!(456)
      ** (Ecto.NoResultsError)

  """
  def get_upload!(id), do: Repo.get!(Upload, id)
  def get_upload(id) do
    id && Repo.get(Upload, id)
  end

  @doc """
  Creates a upload.

  ## Examples

      iex> create_upload(%{field: value})
      {:ok, %Upload{}}

      iex> create_upload(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_upload(attrs \\ %{}) do
    cset = Upload.changeset(%Upload{}, attrs)
    case Repo.insert(cset) do
      {:ok, upload}  ->
        Upload.save_upload_file!(cset, upload)
        Upload.unpack(upload)
        clean_uploads()
        {:ok, upload}
      error ->
        error
    end
  end

  def create_git_upload(attrs \\ %{}) do
    cset = Upload.git_changeset(%Upload{}, attrs)
    case Repo.insert(cset) do
      {:ok, upload}  ->
        clean_uploads()
        {:ok, upload}
      error ->
        error
    end
  end

  def create_fake_upload(owner) do
    attrs = %{
      "user_id" => owner.id,
      "kind" => "sub",
      "name" => "fake-upload.tar.gz",
    }
    cset = Upload.fake_changeset(%Upload{}, attrs)
    case Repo.insert(cset) do
      {:ok, upload}  ->
        Upload.save_upload_file!(cset, upload, :fake)
        Upload.unpack(upload)
        {:ok, upload}
      error ->
        error
    end
  end

  @doc """
  Updates a upload.

  ## Examples

      iex> update_upload(upload, %{field: new_value})
      {:ok, %Upload{}}

      iex> update_upload(upload, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_upload(%Upload{} = upload, attrs) do
    upload
    |> Upload.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Upload.

  ## Examples

      iex> delete_upload(upload)
      {:ok, %Upload{}}

      iex> delete_upload(upload)
      {:error, %Ecto.Changeset{}}

  """
  def delete_upload(%Upload{} = upload) do
    if upload.id && upload.kind != "sub" do
      dpath = Upload.upload_dir(upload)
      if String.length(dpath) > 10 do
        File.rm_rf!(dpath)
        File.rmdir(Path.dirname(dpath))
      end
      Repo.delete(upload)
    end
  end

  def clean_uploads() do
    if Application.get_env(:inkfish, :env) != :test do
      Task.start fn ->
        Inkfish.Uploads.Cleanup.cleanup()
      end
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking upload changes.

  ## Examples

      iex> change_upload(upload)
      %Ecto.Changeset{source: %Upload{}}

  """
  def change_upload(%Upload{} = upload) do
    Upload.changeset(upload, %{})
  end
end
