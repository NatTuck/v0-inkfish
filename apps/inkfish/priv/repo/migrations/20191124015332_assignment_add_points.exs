defmodule Inkfish.Repo.Migrations.AssignmentAddPoints do
  use Ecto.Migration

  alias Inkfish.Repo
  alias Inkfish.Assignments
  alias Inkfish.Assignments.Assignment

  def up do
    alter table("assignments") do
      add :points, :decimal, null: false, default: "0.0"
    end

    flush()

    Repo.all(Assignment)
    |> Enum.each(&Assignments.update_assignment_points!/1)
  end

  def down do
    alter table("assignments") do
      remove :points # :decimal, null: false, default: "0.0"
    end
  end
end
