defmodule Inkfish.Grades.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grades" do
    field :score, :decimal
    belongs_to :sub, Inkfish.Subs.Sub
    belongs_to :grader, Inkfish.Grades.Grader

    belongs_to :grading_user, Inkfish.Users.User

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:grader_id, :sub_id, :score, :grading_user_id])
    |> validate_required([:grader_id, :sub_id])
  end
end
