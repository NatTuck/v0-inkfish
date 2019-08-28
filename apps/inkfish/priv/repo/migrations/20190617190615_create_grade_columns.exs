defmodule Inkfish.Repo.Migrations.CreateGraders do
  use Ecto.Migration

  def change do
    create table(:grade_columns) do
      add :name, :string, null: false
      add :kind, :string, null: false
      add :points, :decimal, null: false
      add :base, :decimal, null: false
      add :params, :string, null: false, default: ""
      add :assignment_id, references(:assignments, on_delete: :delete_all), null: false
      add :upload_id, references(:uploads, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:grade_columns, [:assignment_id])
    create index(:grade_columns, [:upload_id])
  end
end
