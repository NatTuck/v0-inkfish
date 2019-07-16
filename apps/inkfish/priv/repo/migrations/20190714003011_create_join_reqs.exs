defmodule Inkfish.Repo.Migrations.CreateJoinReqs do
  use Ecto.Migration

  def change do
    create table(:join_reqs) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :note, :text
      add :staff_req, :boolean, default: false, null: false

      timestamps()
    end

    create index(:join_reqs, [:course_id])
  end
end
