defmodule Inkfish.Repo.Migrations.CreateGrades do
  use Ecto.Migration

  def change do
    create table(:grades) do
      add :score, :decimal
      add :sub_id, references(:subs, on_delete: :delete_all), null: false
      add :grader_id, references(:graders, on_delete: :delete_all), null: false

      # For "number" graders.
      add :grading_user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:grades, [:sub_id])
    create index(:grades, [:grader_id])
    create index(:grades, [:sub_id, :grader_id], unique: true)
  end
end
