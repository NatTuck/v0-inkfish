defmodule Inkfish.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :active, :boolean, default: true, null: false
      add :teamset_id, references(:teamsets, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:teams, [:teamset_id])
  end
end
