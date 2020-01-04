defmodule Inkfish.Repo.Migrations.GradesAddLogUuid do
  use Ecto.Migration

  def change do
    alter table("grades") do
      add :log_uuid, :string
    end
  end
end
