defmodule Inkfish.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string, null: false
      add :start_date, :date, null: false
      add :footer, :text, null: false, default: ""

      timestamps()
    end

  end
end
