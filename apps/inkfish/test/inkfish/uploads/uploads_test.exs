defmodule Inkfish.UploadsTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Uploads

  describe "uploads" do
    alias Inkfish.Uploads.Upload

    setup do
      base = Upload.upload_base()
      if String.length(base) > 10 && base =~ ~r/test/ do
        File.rm_rf!(base)
      end
      :ok
    end

    def upload_file do
      priv = :code.priv_dir(:inkfish)
      path = Path.join(priv, "test_data/helloc.tar.gz")
      %{ path: path, filename: "helloc.tar.gz" }
    end

    def upload_fixture(attrs \\ %{}) do
      attrs = if attrs[:upload] do
        params_with_assocs(:upload, attrs)
      else
        params_with_assocs(:upload, attrs)
        |> Map.put(:upload, upload_file())
      end

      {:ok, upload} = Uploads.create_upload(attrs)
      upload
    end

    def drop_assocs(%Upload{} = jreq) do
      Map.drop(jreq, [:upload, :user])
    end

    def drop_assocs(ups) do
      Enum.map ups, &drop_assocs/1
    end

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()
      assert drop_assocs(Uploads.list_uploads()) == drop_assocs([upload])
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert drop_assocs(Uploads.get_upload!(upload.id)) == drop_assocs(upload)
    end

    test "create_upload/1 with valid data creates a upload" do
      attrs = params_with_assocs(:upload)
      |> Map.put(:upload, upload_file())

      assert {:ok, %Upload{} = upload} = Uploads.create_upload(attrs)
      assert upload.kind == "assignment_starter"
      assert upload.name == "helloc.tar.gz"
    end

    test "create_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_upload(%{})
    end

    test "delete_upload/1 deletes the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{}} = Uploads.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset" do
      upload = upload_fixture()
      assert %Ecto.Changeset{} = Uploads.change_upload(upload)
    end
  end
end
