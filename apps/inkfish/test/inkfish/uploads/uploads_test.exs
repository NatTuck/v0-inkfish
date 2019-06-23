defmodule Inkfish.UploadsTest do
  use Inkfish.DataCase

  alias Inkfish.Uploads

  describe "uploads" do
    alias Inkfish.Uploads.Upload

    @valid_attrs %{kind: "some kind", name: "some name", nonce: "some nonce"}
    @update_attrs %{kind: "some updated kind", name: "some updated name", nonce: "some updated nonce"}
    @invalid_attrs %{kind: nil, name: nil, nonce: nil}

    def upload_fixture(attrs \\ %{}) do
      {:ok, upload} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Uploads.create_upload()

      upload
    end

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()
      assert Uploads.list_uploads() == [upload]
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert Uploads.get_upload!(upload.id) == upload
    end

    test "create_upload/1 with valid data creates a upload" do
      assert {:ok, %Upload{} = upload} = Uploads.create_upload(@valid_attrs)
      assert upload.kind == "some kind"
      assert upload.name == "some name"
      assert upload.nonce == "some nonce"
    end

    test "create_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_upload(@invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{} = upload} = Uploads.update_upload(upload, @update_attrs)
      assert upload.kind == "some updated kind"
      assert upload.name == "some updated name"
      assert upload.nonce == "some updated nonce"
    end

    test "update_upload/2 with invalid data returns error changeset" do
      upload = upload_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_upload(upload, @invalid_attrs)
      assert upload == Uploads.get_upload!(upload.id)
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
