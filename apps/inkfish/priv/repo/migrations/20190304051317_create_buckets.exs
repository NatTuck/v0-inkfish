defmodule Inkfish.Repo.Migrations.CreateBuckets do
  use Ecto.Migration

  def change do
    create table(:buckets) do
      add :name, :string, null: false
      add :weight, :decimal, null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:buckets, [:course_id])
  end
end
