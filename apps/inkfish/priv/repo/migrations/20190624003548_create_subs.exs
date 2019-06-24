defmodule Inkfish.Repo.Migrations.CreateSubs do
  use Ecto.Migration

  def change do
    create table(:subs) do
      add :active, :boolean, default: false, null: false
      add :score, :decimal
      add :assignment_id, references(:assignments, on_delete: :nothing)
      add :reg_id, references(:regs, on_delete: :nothing)
      add :upload_id, references(:uploads, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:subs, [:assignment_id])
    create index(:subs, [:reg_id])
    create index(:subs, [:upload_id])
  end
end
