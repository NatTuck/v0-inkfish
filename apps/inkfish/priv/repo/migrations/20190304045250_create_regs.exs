defmodule Inkfish.Repo.Migrations.CreateRegs do
  use Ecto.Migration

  def change do
    create table(:regs) do
      add :is_student, :boolean, default: false, null: false
      add :is_prof, :boolean, default: false, null: false
      add :is_staff, :boolean, default: false, null: false
      add :is_grader, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:regs, [:user_id])
    create index(:regs, [:course_id])
    create index(:regs, [:course_id, :user_id], unique: true)
  end
end
