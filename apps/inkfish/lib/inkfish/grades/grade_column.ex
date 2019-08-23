defmodule Inkfish.Grades.GradeColumn do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grade_columns" do
    field :kind, :string
    field :name, :string
    field :params, :string, default: ""
    field :points, :decimal
    belongs_to :assignment, Inkfish.Assignments.Assignment
    belongs_to :upload, Inkfish.Uploads.Upload, type: :binary_id
    has_many :grades, Inkfish.Grades.Grade

    timestamps()
  end

  @doc false
  def changeset(grade_column, attrs) do
    grade_column
    |> cast(attrs, [:assignment_id, :name, :kind, :points, :params, :upload_id])
    |> validate_required([:assignment_id, :name, :kind, :points])
  end

  def grade_column_types do
    ["number", "feedback", "script"]
  end
end
