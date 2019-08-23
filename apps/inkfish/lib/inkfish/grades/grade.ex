defmodule Inkfish.Grades.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grades" do
    field :score, :decimal
    belongs_to :sub, Inkfish.Subs.Sub
    belongs_to :grade_column, Inkfish.Grades.GradeColumn

    belongs_to :grader, Inkfish.Users.User

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:grade_column_id, :sub_id, :score, :grader_id])
    |> validate_required([:grade_column_id, :sub_id])
  end
end
