defmodule Inkfish.Repo.Migrations.CreateSubs do
  use Ecto.Migration

  def change do
    create table(:subs) do
      add :active, :boolean, default: false, null: false
      add :score, :decimal
      add :hours_spent, :decimal, null: false
      add :note, :text
      add :assignment_id, references(:assignments, on_delete: :restrict), null: false
      add :reg_id, references(:regs, on_delete: :restrict), null: false
      add :team_id, references(:teams, on_delete: :restrict), null: false
      add :upload_id, references(:uploads, on_delete: :restrict, type: :binary_id), null: false
      add :git_repo, :string, default: nil

      timestamps()
    end

    create index(:subs, [:assignment_id])
    create index(:subs, [:reg_id])
    create index(:subs, [:upload_id])
  end
end
