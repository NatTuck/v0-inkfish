defmodule Inkfish.Repo.Migrations.CoursesAddSoloTeamId do
  use Ecto.Migration

  def change do
    alter table("courses") do
      add :solo_teamset_id, references(:teamsets, on_delete: :nilify_all)
    end
  end
end
