defmodule Inkfish.Repo.Migrations.CreateTeamsets do
  use Ecto.Migration

  def change do
    create table(:teamsets) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :name, :string, null: false

      timestamps()
    end

    create index(:teamsets, [:course_id])
  end
end
