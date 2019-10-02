defmodule Inkfish.Grades.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "grades" do
    field :score, :decimal
    belongs_to :sub, Inkfish.Subs.Sub
    belongs_to :grade_column, Inkfish.Grades.GradeColumn
    belongs_to :grader, Inkfish.Users.User
    has_many :line_comments, Inkfish.LineComments.LineComment

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:grade_column_id, :sub_id, :score, :grader_id])
    |> validate_required([:grade_column_id, :sub_id])
  end

  def to_map(grade) do
    grade = Map.drop(grade, [:__struct__, :__meta__, :sub, :grade_column, :grader])
    lcs = Enum.map grade.line_comments, fn lc ->
      Inkfish.LineComments.LineComment.to_map(lc)
    end
    %{ grade | line_comments: lcs }
  end
end
