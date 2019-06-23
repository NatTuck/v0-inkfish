defmodule Inkfish.Repo.Migrations.UploadsAddUserId do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :photo_upload_id, references(:uploads, on_delete: :nilify_all, type: :binary_id)
    end
  end
end
