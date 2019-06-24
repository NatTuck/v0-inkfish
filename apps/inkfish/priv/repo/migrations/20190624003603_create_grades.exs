defmodule Inkfish.Repo.Migrations.CreateGrades do
  use Ecto.Migration

  def change do
    create table(:grades) do
      add :score, :decimal
      add :sub_id, references(:subs, on_delete: :nothing)
      add :grader_id, references(:graders, on_delete: :nothing)

      timestamps()
    end

    create index(:grades, [:sub_id])
    create index(:grades, [:grader_id])
  end
end
