defmodule Inkfish.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :reg_id, references(:regs, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:team_members, [:team_id])
    create index(:team_members, [:reg_id])
  end
end
